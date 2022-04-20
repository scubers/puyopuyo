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
class CalculateUtil {
    static func getInitialLayoutResidual(for measure: Measure) -> CGSize {
        func getInitialContentResidual(for sizeDesc: SizeDescription) -> CGFloat {
            switch sizeDesc.sizeType {
            case .fixed:
                return sizeDesc.fixedValue
            case .ratio:
                return 0
            case .wrap:
                return sizeDesc.max
            case .aspectRatio:
                return .greatestFiniteMagnitude
            }
        }

        let contentResidual = CGSize.ensureNotNegative(
            width: getInitialContentResidual(for: measure.size.width),
            height: getInitialContentResidual(for: measure.size.height)
        )

        return getSelfLayoutResidual(for: measure, fromContentResidual: contentResidual)
    }

    static func getSelfLayoutResidual(for measure: Measure, fromContentResidual contentResidual: CGSize) -> CGSize {
        return CGSize.ensureNotNegative(
            width: contentResidual.width + measure.margin.getHorzTotal(),
            height: contentResidual.height + measure.margin.getVertTotal()
        )
    }

    static func getContentResidual(layoutResidual: CGSize, margin: UIEdgeInsets, size: Size) -> CGSize {
        var residual = CGSize.ensureNotNegative(
            width: layoutResidual.width - margin.getHorzTotal(),
            height: layoutResidual.height - margin.getVertTotal()
        )
        if size.width.isFixed { residual.width = size.width.fixedValue }
        if size.height.isFixed { residual.height = size.height.fixedValue }
        // 可能被最大值约束
        residual = residual.clip(by: CGSize(width: size.width.max, height: size.height.max))
        return residual.collapse(to: size.aspectRatio)
    }

    static func getChildrenLayoutResidual(for regulator: Regulator, regulatorLayoutResidual: CGSize) -> CGSize {
        let regulatorContentResidual = getContentResidual(layoutResidual: regulatorLayoutResidual, margin: regulator.margin, size: regulator.size)
        return CGSize.ensureNotNegative(
            width: regulatorContentResidual.width - regulator.padding.getHorzTotal(),
            height: regulatorContentResidual.height - regulator.padding.getVertTotal()
        )
    }

    static func getIntrinsicSize(fromCalculableSize calculableSize: Size, contentResidual: CGSize) -> CGSize {
        assert(calculableSize.bothNotWrap(), "Ensure size is calculable!!!")

        if contentResidual.width == 0 || contentResidual.height == 0 {
            return .zero
        }

        func getIntrinsicLength(_ sizeDesc: SizeDescription, contentResidual: CGFloat) -> CGFloat? {
            switch sizeDesc.sizeType {
            case .fixed:
                return max(0, sizeDesc.fixedValue)
            case .ratio:
                return max(0, contentResidual)
            case .wrap:
                fatalError("SizeType error: \(sizeDesc.sizeType)")
            case .aspectRatio:
                return nil
            }
        }

        var intrinsicWidth = getIntrinsicLength(calculableSize.width, contentResidual: contentResidual.width)
        var intrinsicHeight = getIntrinsicLength(calculableSize.height, contentResidual: contentResidual.height)

        if intrinsicWidth == nil, intrinsicHeight == nil {
            fatalError("Cannot get intrinsic size !!")
        }

        if let aspectRatio = calculableSize.aspectRatio {
            if intrinsicWidth == nil {
                intrinsicWidth = intrinsicHeight! * aspectRatio
            } else if intrinsicHeight == nil {
                intrinsicHeight = intrinsicWidth! / aspectRatio
            }
        }
        let finalSize = CGSize(width: intrinsicWidth!, height: intrinsicHeight!)
        return finalSize
    }

    static func getWrappedContentSize(for measure: Measure, padding: UIEdgeInsets, contentResidual: CGSize, childrenContentSize: CGSize) -> CGSize {
        var contentSize = CGSize(width: childrenContentSize.width + padding.getHorzTotal(), height: childrenContentSize.height + padding.getVertTotal())

        // 内容不能超过 内容剩余空间
        contentSize = contentSize.clip(by: contentResidual)

        // handl width
        switch measure.size.width.sizeType {
        case .fixed:
            contentSize.width = measure.size.width.fixedValue
        case .ratio:
            contentSize.width = contentResidual.width
        case .wrap:
            contentSize.width = min(measure.size.width.getWrapSize(by: contentSize.width), contentResidual.width)
        case .aspectRatio:
            break
        }

        // handle height
        switch measure.size.height.sizeType {
        case .fixed:
            contentSize.height = measure.size.height.fixedValue
        case .ratio:
            contentSize.height = contentResidual.height
        case .wrap:
            contentSize.height = min(measure.size.height.getWrapSize(by: contentSize.height), contentResidual.height)
        case .aspectRatio:
            break
        }

        let finalSize = contentSize.expand(to: measure.size.aspectRatio)
        return finalSize
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
        case lazy
        case positive
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
        if measure.size.maybeWrap() || strategy == .positive {
            size = measure.calculate(by: layoutResidual)
        } else {
            let contentResidual = CalculateUtil.getContentResidual(layoutResidual: layoutResidual, margin: measure.margin, size: measure.size)
            size = CalculateUtil.getIntrinsicSize(fromCalculableSize: measure.size, contentResidual: contentResidual)
        }
        DiagnosisUitl.startDiagnosis(measure: measure, residual: layoutResidual, intrinsic: size, msg: diagnosisMsg)
        return size
    }

    static func sizeThatFit(size: CGSize, to measure: Measure) -> CGSize {
        var layoutResidual = size
        if layoutResidual.width == 0 { layoutResidual.width = .greatestFiniteMagnitude }
        if layoutResidual.height == 0 { layoutResidual.height = .greatestFiniteMagnitude }
        return calculateIntrinsicSize(for: measure, layoutResidual: layoutResidual, strategy: .lazy)
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
    static func ensureNotNegative(width: CGFloat, height: CGFloat) -> CGSize {
        .init(width: max(0, width), height: max(0, height))
    }

    func expand(to aspectRatio: CGFloat?) -> CGSize {
        fit(aspectRatio: aspectRatio, strategy: .expand)
    }

    func collapse(to aspectRatio: CGFloat?) -> CGSize {
        fit(aspectRatio: aspectRatio, strategy: .collapse)
    }

    func clip(by clipper: CGSize) -> CGSize {
        CGSize.ensureNotNegative(width: min(width, clipper.width), height: min(height, clipper.height))
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

        if width == 0 || height == 0 { return self }

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
