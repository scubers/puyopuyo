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
            return max(sizeDesc.min, min(sizeDesc.max, max(0, superRemain - padding - margin)))
        } else {
//            return CGFloat.greatestFiniteMagnitude - padding - margin
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
        var final = CGSize()
        if !size.width.isWrap {
            final.width = getLength(size.width, currentRemain: currentRemain.width, margin: margin.getHorzTotal(), padding: .zero, ratio: ratio?.width)
        }
        if !size.height.isWrap {
            final.height = getLength(size.height, currentRemain: currentRemain.height, margin: margin.getVertTotal(), padding: .zero, ratio: ratio?.height)
        }
        measure.py_size = final
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
        let message = "Constraint conflict: \(msg)"
        if crash {
            fatalError(message)
        } else {
            print(message)
        }
    }
}
