//
//  Caculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import Foundation

class CalculateUtil {
    /// 获取Box在布局子节点时，子节点可使用的最大尺寸
    /// - Parameters:
    ///   - regulator: regulator
    ///   - regulatorResidual: 布局自身可使用的尺寸
    /// - Returns: 子节点布局可以使用的尺寸
    static func getChildrenTotalResidul(for regulator: Regulator, regulatorResidual: CGSize) -> CGSize {
        let regSize = regulator.size
        let margin = regulator.margin
        let padding = regulator.padding

        func getLength(_ sizeDesc: SizeDescription, residual: CGFloat, margin: CGFloat, padding: CGFloat) -> CGFloat {
            if sizeDesc.isFixed {
                // 子布局剩余空间为固有尺寸 - 当前布局内边距
                return max(0, sizeDesc.fixedValue - padding)
            } else if sizeDesc.isRatio {
                // 子布局剩余空间为所有剩余空间
                return max(0, residual - padding - margin)
            } else if sizeDesc.isWrap {
                // 若存在最大值max，需要和最终算出的剩余空间取个最小值
                return max(sizeDesc.min, max(0, min(sizeDesc.max - padding, residual - padding - margin)))
            } else {
                fatalError()
            }
        }

        let width = getLength(regSize.width, residual: regulatorResidual.width, margin: margin.getHorzTotal(), padding: padding.getHorzTotal())
        let height = getLength(regSize.height, residual: regulatorResidual.height, margin: margin.getVertTotal(), padding: padding.getVertTotal())

        return CGSize(width: width, height: height)
    }

    private static func getIntrinsicLength(_ sizeDesc: SizeDescription, residual: CGFloat, margin: CGFloat, padding: CGFloat = 0, wrapValue: CGFloat? = nil) -> CGFloat? {
        switch sizeDesc.sizeType {
        case .fixed:
            return max(0, sizeDesc.fixedValue)
        case .ratio:
            return max(0, residual - margin)
        case .wrap:
            if let value = wrapValue {
                let length = sizeDesc.getWrapSize(by: value + padding)
                // 若剩余空间比最小值还小，则取剩余空间值
                return max(0, min(length, residual - margin))
            } else {
                fatalError("When size is wrap, wrap value must not be nil")
            }
        case .aspectRatio:
            return nil
        }
    }

    /// 根据计算好的 Size 和外部约束，获取固定的CGSize，对结果可能进行 宽高比的扩展
    /// - Parameters:
    ///   - margin: margin
    ///   - residual: residual
    ///   - size: size description
    /// - Returns: intrinsic size
    static func getIntrinsicSize(margin: UIEdgeInsets, residual: CGSize, size: Size) -> CGSize {
        assert(size.width.isFixed || size.width.isRatio)
        assert(size.height.isFixed || size.height.isRatio)

        if residual == .zero {
            return .zero
        }

        var width = getIntrinsicLength(size.width, residual: residual.width, margin: margin.getHorzTotal(), padding: .zero)
        var height = getIntrinsicLength(size.height, residual: residual.height, margin: margin.getVertTotal(), padding: .zero)

        if width == nil, height == nil {
            fatalError("Cannot get intrinsic size !!")
        }

        if let aspectRatio = size.aspectRatio {
            //            assert(residual.width / residual.height == aspectRatio, "Residual must match aspectRatio")
            if width == nil {
                width = height! * aspectRatio
            } else if height == nil {
                height = width! / aspectRatio
            }
        }

        let finalSize = CGSize(width: width!, height: height!)

        //        if let aspectRatio = size.aspectRatio {
        //            finalSize = getAspectRatioSize(finalSize, aspectRatio: aspectRatio, transform: .expand)
        //        }
        return finalSize
    }

    /// 根据布局内容大小当前布局的固有尺寸
    /// - Parameters:
    ///   - regulator: 布局对象
    ///   - residual: 布局可用剩余尺寸
    ///   - contentSize: 布局内部内容尺寸
    /// - Returns: 固有尺寸
    static func getRegulatorIntrinsicSizeByContentSize(_ regulator: Regulator, residual: CGSize, contentSize: CGSize) -> CGSize {
        let margin = regulator.margin
        let padding = regulator.padding
        var regSize = regulator.size

        if regSize.width.isWrap {
            regSize.width = .fix(regSize.width.getWrapSize(by: contentSize.width) + padding.getHorzTotal())
        }
        if regSize.height.isWrap {
            regSize.height = .fix(regSize.height.getWrapSize(by: contentSize.height) + padding.getVertTotal())
        }

        return getIntrinsicSize(margin: margin, residual: residual, size: regSize)

//        let width = getIntrinsicLength(size.width, residual: residual.width, margin: margin.getHorzTotal(), padding: padding.getHorzTotal(), wrapValue: contentSize.width)
//        let height = getIntrinsicLength(size.height, residual: residual.height, margin: margin.getVertTotal(), padding: padding.getVertTotal(), wrapValue: contentSize.height)
//
//        var finalSize = CGSize(width: width, height: height)
//
//        if let aspectRatio = size.aspectRatio {
//            finalSize = getAspectRatioSize(CGSize(width: width, height: height), aspectRatio: aspectRatio, transform: .expand)
//        }
//        return finalSize
    }

    enum CalculateSizeStrategy {
        case intrinsic
        case estimate
    }

    /// 计算一个节点的固有尺寸
    /// - Parameters:
    ///   - measure: 节点描述
    ///   - residual: 节点可用剩余尺寸
    ///   - strategy: 是否立即计算下一个层级，如果存在包裹尺寸则会立即计算下一层级
    /// - Returns: 节点固有尺寸
    static func calculateIntrinsicSize(for measure: Measure, residual: CGSize, strategy: CalculateSizeStrategy, diagnosisMessage: String? = nil) -> CGSize {
        ///
        /// 1. 处理剩余空间坍缩 匹配 aspectRatio
        /// 2. 计算大小
        /// 3. 处理大小扩充 匹配 aspectRatio

        let aspectRatio = measure.size.aspectRatio
        let finalResidual = CalculateUtil.getAspectRatioSize(residual, aspectRatio: aspectRatio, transform: .collapse)

        var size: CGSize
        if measure.size.maybeWrap() || strategy == .intrinsic {
            size = measure.calculate(by: finalResidual)
        } else {
            var width = getIntrinsicLength(measure.size.width, residual: finalResidual.width, margin: measure.margin.getHorzTotal())
            var height = getIntrinsicLength(measure.size.height, residual: finalResidual.height, margin: measure.margin.getVertTotal())

            assert(!(width == nil && height == nil))

            if let aspectRatio = aspectRatio {
                if height == nil { height = width! / aspectRatio }
                if width == nil { width = height! * aspectRatio }
            }

            size = CGSize(width: width!, height: height!)
        }

        let finalSize = CalculateUtil.getAspectRatioSize(size, aspectRatio: aspectRatio, transform: .expand)
        startCalculateDiagnosis(measure: measure, residual: residual, intrinsic: finalSize, msg: diagnosisMessage)
        return finalSize
    }

    private static func startCalculateDiagnosis(measure: Measure, residual: CGSize, intrinsic: CGSize, msg: String?) {
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

    /// 允许size 存在0的情况，则视为不限制
    static func sizeThatFit(size: CGSize, to measure: Measure) -> CGSize {
        var residual = size
        if residual.width == 0 { residual.width = .greatestFiniteMagnitude }
        if residual.height == 0 { residual.height = .greatestFiniteMagnitude }
        return calculateIntrinsicSize(for: measure, residual: residual, strategy: .estimate)
    }

    static func constraintConflict(crash: Bool, _ msg: String) {
        let message = "[Puyopuyo] Constraint conflict: \(msg)"
        if crash {
            fatalError(message)
        } else {
            print(message)
        }
    }

    static func calculateCrossAlignmentOffset(_ measure: Measure,
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

    enum AspectRatioTransform {
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
    static func getAspectRatioSize(_ size: CGSize, aspectRatio: CGFloat?, transform: AspectRatioTransform) -> CGSize {
        guard let aspectRatio = aspectRatio, aspectRatio > 0 else {
            return size
        }

        if size.width == 0 || size.height == 0 { return size }

        let currentAspectRatio = size.width / size.height

        if currentAspectRatio == aspectRatio { return size }

        var finalResidual = size

        if currentAspectRatio > aspectRatio {
            switch transform {
            case .expand:
                finalResidual.height = size.width / aspectRatio
            case .collapse:
                finalResidual.width = size.height * aspectRatio
            }

        } else if currentAspectRatio < aspectRatio {
            switch transform {
            case .expand:
                finalResidual.width = size.height * aspectRatio
            case .collapse:
                finalResidual.height = size.width / aspectRatio
            }
        }

        return finalResidual
    }

    /// 根据宽高比获取合理的尺寸
    static func getAspectRatioResidual(for measure: Measure, residual: CGSize, transform: AspectRatioTransform) -> CGSize {
        guard let aspectRatio = measure.size.aspectRatio, !measure.size.maybeFixed() else {
            return residual
        }
        let margin = measure.margin
        let size = getAspectRatioSize(CGSize(width: residual.width - margin.getHorzTotal(), height: residual.height - margin.getVertTotal()), aspectRatio: aspectRatio, transform: transform)
        return CGSize(width: size.width + margin.getHorzTotal(), height: size.height + margin.getVertTotal())
    }
}
