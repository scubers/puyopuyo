//
//  Caculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import Foundation

class Caculator {
    struct Ratio {
        var width: CGFloat?
        var height: CGFloat?
    }

    // remain 剩余空间，标记当前view布局的时候，父view给予的剩余空间
    // margin 当前view布局时候的margin
    // padding 当前view的padding（如果有）
    // ratio 当前尺寸计算时，如果desc为ratio时依赖计算的总ratio，若为空，则取desc的ratio值，相当于比例为1

    static func getChildRemainLength(_ sizeDesc: SizeDescription,
                                     superRemain: CGFloat,
                                     margin: CGFloat,
                                     padding: CGFloat,
                                     ratio: CGFloat?) -> CGFloat {
        if sizeDesc.isFixed {
            // 子布局剩余空间为固有尺寸 - 当前布局内边距
            return max(0, sizeDesc.fixedValue - padding)
        } else if sizeDesc.isRatio {
            // 子布局剩余空间为
            let totalRatio = ratio ?? sizeDesc.ratio
            return max(0, (sizeDesc.ratio / totalRatio) * (superRemain - padding - margin))
        } else if sizeDesc.isWrap {
            // 若存在最大值max，需要和最终算出的剩余空间取个最小值
            return max(sizeDesc.min, max(0, min(sizeDesc.max - padding, superRemain - padding - margin)))
        } else {
            fatalError()
        }
    }

    static func getChildRemainSize(_ size: Size, superRemain: CGSize, margin: UIEdgeInsets, padding: UIEdgeInsets, ratio: Ratio?) -> CGSize {
        let width = getChildRemainLength(size.width, superRemain: superRemain.width, margin: margin.getHorzTotal(), padding: padding.getHorzTotal(), ratio: ratio?.width)
        let height = getChildRemainLength(size.height, superRemain: superRemain.height, margin: margin.getVertTotal(), padding: padding.getVertTotal(), ratio: ratio?.height)
        return CGSize(width: width, height: height)
    }

    static func getLength(_ sizeDesc: SizeDescription, currentRemain: CGFloat, margin: CGFloat, padding: CGFloat, ratio: CGFloat?) -> CGFloat {
        if sizeDesc.isFixed {
            return max(0, sizeDesc.fixedValue)
        } else if sizeDesc.isRatio {
            let totalRatio = ratio ?? sizeDesc.ratio
            return max(0, (sizeDesc.ratio / totalRatio) * (currentRemain - margin - padding))
        } else {
            fatalError()
        }
    }

    static func applyMeasure(_ measure: Measure, size: Size, currentRemain: CGSize, ratio: Ratio?) {
        // 把size应用到measure上，只关心剩余空间
        let margin = measure.margin
        if !size.width.isWrap {
            let width = getLength(size.width, currentRemain: currentRemain.width, margin: margin.getHorzTotal(), padding: .zero, ratio: ratio?.width)
            if width != measure.py_size.width {
                measure.py_size.width = width
            }
        }
        if !size.height.isWrap {
            let height = getLength(size.height, currentRemain: currentRemain.height, margin: margin.getVertTotal(), padding: .zero, ratio: ratio?.height)
            if height != measure.py_size.height {
                measure.py_size.height = height
            }
        }
    }

    static func getSize(_ regulator: Regulator, currentRemain: CGSize, wrapContentSize: CGSize) -> CGSize {
        let margin = regulator.margin
        let size = regulator.size
        var final = CGSize()
        if size.width.isWrap {
            final.width = regulator.size.width.getWrapSize(by: wrapContentSize.width + regulator.padding.left + regulator.padding.right)
        } else {
            final.width = getLength(size.width, currentRemain: currentRemain.width, margin: margin.getHorzTotal(), padding: .zero, ratio: nil)
        }
        if size.height.isWrap {
            final.height = regulator.size.height.getWrapSize(by: wrapContentSize.height + regulator.padding.top + regulator.padding.bottom)
        } else {
            final.height = getLength(size.height, currentRemain: currentRemain.height, margin: margin.getVertTotal(), padding: .zero, ratio: nil)
        }
        return final
    }

    /// 计算非wrap的size
    static func caculate(size: Size, by cgSize: CGSize) -> Size {
        let width = caculateFix(size.width, by: cgSize.width)
        let height = caculateFix(size.height, by: cgSize.height)
        return Size(width: width, height: height)
    }

    static func caculateFix(_ size: SizeDescription, by relayLength: CGFloat) -> SizeDescription {
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
        let temp = Measure()
        temp.py_size = size
        var remain = size
        if remain.width == 0 { remain.width = .greatestFiniteMagnitude }
        if remain.height == 0 { remain.height = .greatestFiniteMagnitude }
        // 父视图为非Regulator，需要事先应用一下固有尺寸
        Caculator.applyMeasure(measure, size: measure.size, currentRemain: remain, ratio: nil)
        let sizeAfterCalulate = measure.caculate(byParent: temp, remain: remain)
        let fixedSize = Caculator.caculate(size: sizeAfterCalulate, by: size)
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

    static func caculateCrossAlignmentOffset(_ measure: Measure,
                                             direction: Direction,
                                             justifyContent: Alignment,
                                             parentPadding: UIEdgeInsets,
                                             parentSize: CGSize) -> CGFloat {
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
                constraintConflict(crash: false, "[\(measure.getRealTarget())]'s Alignment ratio can only activate when alignment == *center")
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
