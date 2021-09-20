//
//  Caculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import Foundation

class Calculator {
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

    private static func getIntrinsicLength(_ sizeDesc: SizeDescription, residual: CGFloat, margin: CGFloat, padding: CGFloat? = nil, wrapValue: CGFloat? = nil) -> CGFloat {
        if sizeDesc.isFixed {
            return max(0, sizeDesc.fixedValue)
        } else if sizeDesc.isRatio {
            return max(0, residual - margin)
        } else {
            if let value = wrapValue, let padding = padding {
                return sizeDesc.getWrapSize(by: value + padding)
            } else {
                fatalError("when size is wrap, wrap value and padding must not be nil")
            }
        }
    }

    /// 根据已经计算好的内容获取固有尺寸
    static func getIntrinsicSize(margin: UIEdgeInsets, residual: CGSize, size: Size) -> CGSize {
        assert(size.bothNotWrap(), "cannot get intrinsci size from wrap size")
        let width = getIntrinsicLength(size.width, residual: residual.width, margin: margin.getHorzTotal(), padding: .zero)
        let height = getIntrinsicLength(size.height, residual: residual.height, margin: margin.getVertTotal(), padding: .zero)

        var finalSize = CGSize(width: width, height: height)

        if let aspectRatio = size.aspectRatio /* , !(height == 0 && width == 0) */ {
            finalSize = getAspectRatioSize(CGSize(width: width, height: height), aspectRatio: aspectRatio, transform: .max)
        }
        return finalSize
    }

    /// 根据计算好的内容获取当前布局的固有尺寸
    /// - Parameters:
    ///   - regulator: 布局对象
    ///   - residual: 布局可用剩余尺寸
    ///   - contentSize: 布局内部内容尺寸
    /// - Returns: 固有尺寸
    static func getRegulatorIntrinsicSize(_ regulator: Regulator, residual: CGSize, contentSize: CGSize) -> CGSize {
        let margin = regulator.margin
        let padding = regulator.padding
        let size = regulator.size

        let width = getIntrinsicLength(size.width, residual: residual.width, margin: margin.getHorzTotal(), padding: padding.getHorzTotal(), wrapValue: contentSize.width)
        let height = getIntrinsicLength(size.height, residual: residual.height, margin: margin.getVertTotal(), padding: padding.getVertTotal(), wrapValue: contentSize.height)

        var finalSize = CGSize(width: width, height: height)

        if let aspectRatio = size.aspectRatio, !regulator.size.maybeFixed() {
            finalSize = getAspectRatioSize(CGSize(width: width, height: height), aspectRatio: aspectRatio, transform: .max)
        }
        return finalSize
    }

    /// 计算一个节点的固有尺寸
    /// - Parameters:
    ///   - measure: 节点描述
    ///   - residual: 节点可用剩余尺寸
    ///   - calculateChildrenImmediately: 是否立即计算下一个层级
    /// - Returns: 节点固有尺寸
    static func calculateIntrinsicSize(for measure: Measure, residual: CGSize, calculateChildrenImmediately: Bool, diagnosisMessage: String? = nil) -> CGSize {
        let finalResidual = Calculator.getAspectRatioResidual(for: measure, residual: residual, transform: .min)
        var intrinsic: CGSize
        if measure.size.maybeWrap() || calculateChildrenImmediately {
            intrinsic = measure.calculate(by: finalResidual)
        } else {
            var s = measure.size
            if s.isFixed() { s.aspectRatio = nil }
            intrinsic = Calculator.getIntrinsicSize(margin: measure.margin, residual: finalResidual, size: s)
        }
        startCalculateDiagnosis(measure: measure, residual: residual, intrinsic: intrinsic, msg: diagnosisMessage)
        return intrinsic
    }

    static func startCalculateDiagnosis(measure: Measure, residual: CGSize, intrinsic: CGSize, msg: String?) {
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
        return calculateIntrinsicSize(for: measure, residual: residual, calculateChildrenImmediately: false)
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
        case max
        case min
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
            case .max:
                finalResidual.height = size.width / aspectRatio
            case .min:
                finalResidual.width = size.height * aspectRatio
            }

        } else if currentAspectRatio < aspectRatio {
            switch transform {
            case .max:
                finalResidual.width = size.height * aspectRatio
            case .min:
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
