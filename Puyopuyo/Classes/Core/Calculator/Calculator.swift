//
//  Caculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import Foundation

class Calculator {
    // residual 剩余空间，标记当前view布局的时候，父view给予的剩余空间
    // margin 当前view布局时候的margin
    // padding 当前view的padding（如果有）
    // ratio 当前尺寸计算时，如果desc为ratio时依赖计算的总ratio，若为空，则取desc的ratio值，相当于比例为1
    static func getChildResidualLength(_ sizeDesc: SizeDescription,
                                       residual: CGFloat,
                                       margin: CGFloat,
                                       padding: CGFloat) -> CGFloat
    {
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

    static func getChildResidualSize(_ size: Size, residual: CGSize, margin: UIEdgeInsets, padding: UIEdgeInsets) -> CGSize {
        let width = getChildResidualLength(size.width, residual: residual.width, margin: margin.getHorzTotal(), padding: padding.getHorzTotal())
        let height = getChildResidualLength(size.height, residual: residual.height, margin: margin.getVertTotal(), padding: padding.getVertTotal())
        return CGSize(width: width, height: height)
    }

    static func getIntrinsicLength(_ sizeDesc: SizeDescription, residual: CGFloat, margin: CGFloat, padding: CGFloat? = nil, wrapValue: CGFloat? = nil) -> CGFloat {
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

    static func getIntrinsicSize(margin: UIEdgeInsets, residual: CGSize, size: Size) -> CGSize {
        assert(size.bothNotWrap(), "cannot get intrinsci size from wrap size")
        var width = getIntrinsicLength(size.width, residual: residual.width, margin: margin.getHorzTotal(), padding: .zero)
        var height = getIntrinsicLength(size.height, residual: residual.height, margin: margin.getVertTotal(), padding: .zero)

        if let aspectRatio = size.aspectRatio, !(height == 0 && width == 0), false {
            if width == 0 {
                width = aspectRatio * height
            } else if height == 0 {
                height = width / aspectRatio
            } else {
                // w h 都有值
                let currentRatio = width / height
                if currentRatio > aspectRatio {
                    height = width / aspectRatio
                } else if currentRatio < aspectRatio {
                    width = height * aspectRatio
                }
            }
        }
        return CGSize(width: width, height: height)
    }

    static func applyMeasure(_ measure: Measure, size: Size, currentResidual: CGSize) {
        let intrinsicSize = getIntrinsicSize(margin: measure.margin, residual: currentResidual, size: size)
        measure.py_size = intrinsicSize
    }

    static func getRegulatorIntrinsicSize(_ regulator: Regulator, residual: CGSize, contentSize: CGSize) -> CGSize {
        let margin = regulator.margin
        let padding = regulator.padding
        let size = regulator.size

        let width = getIntrinsicLength(size.width, residual: residual.width, margin: margin.getHorzTotal(), padding: padding.getHorzTotal(), wrapValue: contentSize.width)
        let height = getIntrinsicLength(size.height, residual: residual.height, margin: margin.getVertTotal(), padding: padding.getVertTotal(), wrapValue: contentSize.height)

        return CGSize(width: width, height: height)
    }

    /// 允许size 存在0的情况，则视为不限制
    static func sizeThatFit(size: CGSize, to measure: Measure) -> CGSize {
        var residual = size
        if residual.width == 0 { residual.width = .greatestFiniteMagnitude }
        if residual.height == 0 { residual.height = .greatestFiniteMagnitude }
        return measure.calculate(by: residual)
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
        let subFixedSize = measure.py_size.getCalFixedSize(by: direction)

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
}
