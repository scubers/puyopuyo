//
//  Caculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import Foundation

///
/// 相关概念：
/// layoutResidual: 提供给 布局 参与布局的空间（包含margin）
/// contentResidual: View 实际可用的最大空间（不包含margin），且必须满足 size.aspectRatio 的宽高比
struct CalculateUtil {
    /// 获取布局时候的初始化LayoutResidual
    /// - Parameter measure: measure description
    /// - Parameter constraint: constraint description
    /// - Returns: layoutResidual
    static func getInitialLayoutResidual(for measure: Measure, contentConstraint: CGSize = .init(width: -1, height: -1)) -> CGSize {
        func getInitialContentResidual(for sizeDesc: SizeDescription, constraint: CGFloat) -> CGFloat {
            switch sizeDesc.sizeType {
            case .fixed:
                return sizeDesc.fixedValue
            case .ratio:
                return constraint < 0 ? 0 : constraint
            case .wrap:
                return constraint < 0 ? sizeDesc.max : constraint
            case .aspectRatio:
                return constraint < 0 ? .greatestFiniteMagnitude : constraint
            }
        }

        let contentResidual = CGSize(
            width: getInitialContentResidual(for: measure.size.width, constraint: contentConstraint.width),
            height: getInitialContentResidual(for: measure.size.height, constraint: contentConstraint.height)
        )
        .ensureNotNegative()

        return getSelfLayoutResidual(for: measure, fromContentResidual: contentResidual)
    }

    /// 已知当前节点的内容尺寸，获取其布局时的最小剩余布局
    /// - Parameters:
    ///   - measure: measure
    ///   - contentResidual: contentResidual description
    /// - Returns: layoutResidual
    static func getSelfLayoutResidual(for measure: Measure, fromContentResidual contentResidual: CGSize) -> CGSize {
        return contentResidual
            .expand(edge: measure.margin)
            .ensureNotNegative()
    }

    /// 根据layoutResidual和相关约束，获取当前节点的contentResidual
    /// - Parameters:
    ///   - layoutResidual: layoutResidual description
    ///   - margin: margin description
    ///   - size: size description
    /// - Returns: contentResidual
    static func getContentResidual(layoutResidual: CGSize, margin: UIEdgeInsets, size: Size) -> CGSize {
        var residual = layoutResidual
            .collapse(edge: margin)
            .ensureNotNegative()
        if size.width.isFixed { residual.width = size.width.fixedValue }
        if size.height.isFixed { residual.height = size.height.fixedValue }
        // 可能被最大值约束
        residual = residual.clip(by: CGSize(width: size.width.max, height: size.height.max))
        return residual.collapse(to: size.aspectRatio)
    }

    static func getChildrenLayoutResidual(for regulator: Regulator, regulatorLayoutResidual: CGSize) -> CGSize {
        let regulatorContentResidual = getContentResidual(layoutResidual: regulatorLayoutResidual, margin: regulator.margin, size: regulator.size)
        return regulatorContentResidual
            .collapse(edge: regulator.padding)
            .ensureNotNegative()
    }

    static func getIntrinsic(from sizeDesc: SizeDescription, contentResidual: CGFloat, wrappedContent: CGFloat?) -> CGFloat {
        guard contentResidual > 0 else {
            return 0
        }
        switch sizeDesc.sizeType {
        case .fixed:
            return Swift.max(0, sizeDesc.fixedValue)
        case .ratio:
            return Swift.max(0, contentResidual)
        case .wrap:
            assert(wrappedContent != nil)
            return Swift.min(sizeDesc.getWrapSize(by: wrappedContent!), contentResidual)
        case .aspectRatio:
            return 0
        }
    }

    static func getIntrinsicSize(from size: Size, contentResidual: CGSize, wrappedContent: CGSize? = nil) -> CGSize {
        if size.maybeWrap {
            assert(wrappedContent != nil)
        }
        // 约束包裹内容
        let content = wrappedContent?.clip(by: contentResidual)

        let width = getIntrinsic(from: size.width, contentResidual: contentResidual.width, wrappedContent: content?.width)
        let height = getIntrinsic(from: size.height, contentResidual: contentResidual.height, wrappedContent: content?.height)

        let intrinsic = CGSize(width: width, height: height)
        return intrinsic.expand(to: size.aspectRatio)
    }

    static func getCalculatedChildCrossAlignmentOffset(_ measure: Measure,
                                                       direction: Direction,
                                                       justifyContent: Alignment,
                                                       parentPadding: UIEdgeInsets,
                                                       parentSize: CGSize) -> CGFloat
    {
        let parentCalSize = parentSize.getCalFixedSize(by: direction)
        let parentCalPadding = parentPadding.getCalEdges(by: direction)

        let subCalMargin = measure.margin.getCalEdges(by: direction)
        let subFixedSize = measure.calculatedSize.getCalFixedSize(by: direction)

        let subCrossAligment: Alignment = measure.alignment.hasCrossAligment(for: direction) ? measure.alignment : justifyContent

        let crossAligmentRatio = direction == .x ? subCrossAligment.centerRatio.y : subCrossAligment.centerRatio.x

        var position = ((parentCalSize.cross - parentCalPadding.crossFixed - subFixedSize.cross - subCalMargin.crossFixed) / 2) * (crossAligmentRatio + 1) + parentCalPadding.forward + subFixedSize.cross / 2 + subCalMargin.forward

        if subCrossAligment.isForward(for: direction) {
            position = parentCalPadding.forward + subCalMargin.forward + subFixedSize.cross / 2
        } else if subCrossAligment.isBackward(for: direction) {
            position = parentCalSize.cross - (parentCalPadding.backward + subCalMargin.backward + subFixedSize.cross / 2)
        }

        return position
    }

    enum FitAspectRatioStrategy {
        case expand
        case collapse
    }

    static func fit(_ size: CGSize, aspectRatio: CGFloat?, strategy: FitAspectRatioStrategy) -> CGSize {
        switch strategy {
        case .expand:
            return size.expand(to: aspectRatio)
        case .collapse:
            return size.collapse(to: aspectRatio)
        }
    }
}

enum CalHelper {
    enum CalculateStrategy {
        case estimate
        case calculate
    }

    /// Measure 节点计算的统一入口
    /// `strategy`
    /// - Parameters:
    ///   - measure: measure
    ///   - layoutResidual: layoutResidual description
    ///   - strategy: positive: 同时计算子节点; negative: 若节点非包裹，则使用预估尺寸，子节点不会参与计算
    ///   - diagnosisMsg: diagnosisMsg description
    /// - Returns: Content size
    static func calculateIntrinsicSize(for measure: Measure, layoutResidual: CGSize, strategy: CalculateStrategy, diagnosisMsg: String? = nil) -> CGSize {
        var size: CGSize
        if measure.size.maybeWrap || strategy == .calculate {
            size = measure.calculate(by: layoutResidual)
        } else {
            size = getEstimateIntrinsic(for: measure, layoutResidual: layoutResidual)
        }
        DiagnosisUitl.startDiagnosis(measure: measure, residual: layoutResidual, intrinsic: size, msg: diagnosisMsg)
        return size
    }

    /// 不通过计算子节点获取估算尺寸，当size maybeWrap时不可用
    /// - Parameters:
    ///   - measure: measure description
    ///   - layoutResidual: layoutResidual description
    /// - Returns: description
    static func getEstimateIntrinsic(for measure: Measure, layoutResidual: CGSize) -> CGSize {
        assert(measure.size.bothNotWrap)
        let contentResidual = CalculateUtil.getContentResidual(layoutResidual: layoutResidual, margin: measure.margin, size: measure.size)
        return CalculateUtil.getIntrinsicSize(from: measure.size, contentResidual: contentResidual)
    }

    static func sizeThatFit(size: CGSize, to measure: Measure) -> CGSize {
        var layoutResidual = size
        if layoutResidual.width == 0 { layoutResidual.width = .greatestFiniteMagnitude }
        if layoutResidual.height == 0 { layoutResidual.height = .greatestFiniteMagnitude }
        return calculateIntrinsicSize(for: measure, layoutResidual: layoutResidual, strategy: .estimate)
    }
}

extension Comparable {
    mutating func replaceIfLarger(_ value: Self) {
        self = Swift.max(value, self)
    }

    mutating func replaceIfSmaller(_ value: Self) {
        self = Swift.min(value, self)
    }
}

extension CGSize {
    func ensureNotNegative() -> CGSize {
        return CGSize(width: Swift.max(0, width), height: Swift.max(0, height))
    }

    func expand(to aspectRatio: CGFloat?) -> CGSize {
        fit(aspectRatio: aspectRatio, strategy: .expand)
    }

    func collapse(to aspectRatio: CGFloat?) -> CGSize {
        fit(aspectRatio: aspectRatio, strategy: .collapse)
    }

    func clip(by clipper: CGSize) -> CGSize {
        CGSize(width: Swift.min(width, clipper.width), height: Swift.min(height, clipper.height))
            .ensureNotNegative()
    }

    func expand(edge: UIEdgeInsets) -> CGSize {
        return CGSize(width: width + edge.getHorzTotal(), height: height + edge.getVertTotal())
    }

    func collapse(edge: UIEdgeInsets) -> CGSize {
        return CGSize(width: width - edge.getHorzTotal(), height: height - edge.getVertTotal())
    }

    enum FitAspectRatioStrategy {
        case expand
        case collapse
    }

    /// 根据提供的尺寸和宽高比，获取合理的尺寸
    ///
    /// - Parameters:
    ///   - size: Original size
    ///   - aspectRatio: aspectRatio
    ///   - expand: if true, return the max size, otherwise the min size
    /// - Returns: The result size
    func fit(aspectRatio: CGFloat?, strategy: FitAspectRatioStrategy) -> CGSize {
        guard let aspectRatio = aspectRatio, aspectRatio > 0 else {
            return self
        }

        guard self != .zero else {
            return .zero
        }

        guard width != 0, height != 0 else {
            // 任意一个为0，则单一规则
            switch strategy {
            case .collapse: return .zero
            case .expand:
                if width == 0 {
                    return CGSize(width: height * aspectRatio, height: height)
                } else {
                    return CGSize(width: width, height: width / aspectRatio)
                }
            }
        }

        let currentAspectRatio = width / height

        if currentAspectRatio == aspectRatio { return self }

        var finalResidual = self

        if currentAspectRatio > aspectRatio {
            switch strategy {
            case .expand:
                finalResidual.height = width / aspectRatio
            case .collapse:
                finalResidual.width = height * aspectRatio
            }

        } else if currentAspectRatio < aspectRatio {
            switch strategy {
            case .expand:
                finalResidual.width = height * aspectRatio
            case .collapse:
                finalResidual.height = width / aspectRatio
            }
        }

        return finalResidual
    }
}

extension CGFloat {
    func clipDecimal(_ value: Int) -> CGFloat {
        let sign: CGFloat = value > 0 ? 1 : -1
        let intValue = Int(Swift.abs(self))
        let decimalValue = Swift.abs(self) - CGFloat(intValue)
        let factor = pow(10, CGFloat(value))
        let decimal = CGFloat(Int(decimalValue * factor)) / factor
        return (CGFloat(intValue) + decimal) * sign
    }
}

enum DiagnosisUitl {
    static func startDiagnosis(measure: Measure, residual: CGSize, intrinsic: CGSize, msg: String?) {
        #if DEBUG
        guard measure.diagnosisId != nil else { return }
        let content = """

        >>>>>>>>>> [Calculation diagnosis\(msg == nil ? "" : ": \(msg!)")] >>>>>>>>>>
        \(measure.diagnosisMessage)
        >>>>>>>>>> Result
        - Residual: [width: \(residual.width), height: \(residual.height)]
        - Intrinsic: [width: \(intrinsic.width), height: \(intrinsic.height)]
        >>>>>>>>>> [Calculation diagnosis] >>>>>>>>>>

        """
        print(content)
        #endif
    }

    static func constraintConflict(crash: Bool, _ msg: String) {
        #if DEBUG
        let message = "[Puyopuyo] Constraint conflict: \(msg)"
        if crash {
            fatalError(message)
        } else {
            print(message)
        }
        #endif
    }
}
