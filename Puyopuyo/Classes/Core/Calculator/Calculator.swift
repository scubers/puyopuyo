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
                                       superResidual: CGFloat,
                                       margin: CGFloat,
                                       padding: CGFloat) -> CGFloat
    {
        if sizeDesc.isFixed {
            // 子布局剩余空间为固有尺寸 - 当前布局内边距
            return max(0, sizeDesc.fixedValue - padding)
        } else if sizeDesc.isRatio {
            // 子布局剩余空间为所有剩余空间
            return max(0, superResidual - padding - margin)
        } else if sizeDesc.isWrap {
            // 若存在最大值max，需要和最终算出的剩余空间取个最小值
            return max(sizeDesc.min, max(0, min(sizeDesc.max - padding, superResidual - padding - margin)))
        } else {
            fatalError()
        }
    }

    static func getChildResidualSize(_ size: Size, superResidual: CGSize, margin: UIEdgeInsets, padding: UIEdgeInsets) -> CGSize {
        let width = getChildResidualLength(size.width, superResidual: superResidual.width, margin: margin.getHorzTotal(), padding: padding.getHorzTotal())
        let height = getChildResidualLength(size.height, superResidual: superResidual.height, margin: margin.getVertTotal(), padding: padding.getVertTotal())
        return CGSize(width: width, height: height)
    }

    static func getLength(_ sizeDesc: SizeDescription, currentResidual: CGFloat, margin: CGFloat, padding: CGFloat) -> CGFloat {
        if sizeDesc.isFixed {
            return max(0, sizeDesc.fixedValue)
        } else if sizeDesc.isRatio {
            return max(0, currentResidual - margin - padding)
        } else {
            fatalError()
        }
    }

    static func applyMeasure(_ measure: Measure, size: Size, currentResidual: CGSize) {
        // 把size应用到measure上，只关心剩余空间
        let margin = measure.margin
        if !size.width.isWrap {
            let width = getLength(size.width, currentResidual: currentResidual.width, margin: margin.getHorzTotal(), padding: .zero)
            if width != measure.py_size.width {
                measure.py_size.width = width
            }
        }
        if !size.height.isWrap {
            let height = getLength(size.height, currentResidual: currentResidual.height, margin: margin.getVertTotal(), padding: .zero)
            if height != measure.py_size.height {
                measure.py_size.height = height
            }
        }
    }

    static func getSize(_ regulator: Regulator, currentResidual: CGSize, wrapContentSize: CGSize) -> CGSize {
        let margin = regulator.margin
        let size = regulator.size
        var final = CGSize()
        if size.width.isWrap {
            final.width = regulator.size.width.getWrapSize(by: wrapContentSize.width + regulator.padding.left + regulator.padding.right)
        } else {
            final.width = getLength(size.width, currentResidual: currentResidual.width, margin: margin.getHorzTotal(), padding: .zero)
        }
        if size.height.isWrap {
            final.height = regulator.size.height.getWrapSize(by: wrapContentSize.height + regulator.padding.top + regulator.padding.bottom)
        } else {
            final.height = getLength(size.height, currentResidual: currentResidual.height, margin: margin.getVertTotal(), padding: .zero)
        }
        return final
    }

    /// 计算非wrap的size
    static func calculate(size: Size, by cgSize: CGSize) -> Size {
        let width = calculateFix(size.width, by: cgSize.width)
        let height = calculateFix(size.height, by: cgSize.height)
        return Size(width: width, height: height)
    }

    static func calculateFix(_ size: SizeDescription, by relayLength: CGFloat) -> SizeDescription {
        guard !size.isWrap else {
            fatalError("不能计算包裹尺寸")
        }
        if size.isFixed {
            return size
        }
        if size.isRatio {
            return .fix(relayLength)
        }
        fatalError()
    }

    /// 允许size 存在0的情况，则视为不限制
    static func sizeThatFit(size: CGSize, to measure: Measure) -> CGSize {
        var residual = size
        if residual.width == 0 { residual.width = .greatestFiniteMagnitude }
        if residual.height == 0 { residual.height = .greatestFiniteMagnitude }
        // 父视图为非Regulator，需要事先应用一下固有尺寸
        Calculator.applyMeasure(measure, size: measure.size, currentResidual: residual)
        let sizeAfterCalulate = measure.calculate(by: residual)
        let fixedSize = Calculator.calculate(size: sizeAfterCalulate, by: size)
        return CGSize(width: fixedSize.width.fixedValue, height: fixedSize.height.fixedValue)
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

        let crossAligmentRatio = direction == .x ? measure.alignmentRatio.height : measure.alignmentRatio.width

        let subCrossAligment: Alignment = measure.alignment.hasCrossAligment(for: direction) ? measure.alignment : justifyContent

        var position = ((parentCalSize.cross - parentCalPadding.crossFixed - subFixedSize.cross - subCalMargin.crossFixed) / 2) * crossAligmentRatio + parentCalPadding.forward + subFixedSize.cross / 2 + subCalMargin.forward

        func alignmentConflictCheck() {
            #if DEBUG
            if crossAligmentRatio != 1 {
                constraintConflict(crash: false, "[\(measure.getRealDelegate())]'s Alignment ratio can only activate when alignment == *center")
            }
            #endif
        }

        if subCrossAligment.isForward(for: direction) {
            position = parentCalPadding.forward + subCalMargin.forward + subFixedSize.cross / 2
            alignmentConflictCheck()
        } else if subCrossAligment.isBackward(for: direction) {
            position = parentCalSize.cross - (parentCalPadding.backward + subCalMargin.backward + subFixedSize.cross / 2)
            alignmentConflictCheck()
        }

        return position
    }
}
