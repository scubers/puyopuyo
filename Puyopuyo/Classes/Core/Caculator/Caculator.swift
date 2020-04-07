//
//  Caculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import Foundation

class Caculator {
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
//            return .fix(size.ratio * relayLength)
            return .fix(relayLength)
        }
        fatalError()
    }

    static func caculate(calSize: CalSize, by fixedSize: CalFixedSize) -> CalSize {
        guard !calSize.main.isWrap, !calSize.cross.isWrap else {
            fatalError("不能计算包裹size")
        }

        var main = calSize.main
        if main.isRatio {
            main = .fix(main.ratio * fixedSize.main)
        }

        var cross = calSize.cross
        if cross.isRatio {
            cross = .fix(cross.ratio * fixedSize.cross)
        }
        return CalSize(main: main, cross: cross, direction: calSize.direction)
    }

    /// 允许size 存在0的情况，则视为不限制
    static func sizeThatFit(size: CGSize, to measure: Measure) -> CGSize {
        let temp = Measure()
        temp.py_size = size
        var remain = size
        if remain.width == 0 { remain.width = .greatestFiniteMagnitude }
        if remain.height == 0 { remain.height = .greatestFiniteMagnitude }
        let sizeAfterCalulate = measure.caculate(byParent: temp, remain: remain)
        let fixedSize = Caculator.caculate(size: sizeAfterCalulate, by: size)
        return CGSize(width: fixedSize.width.fixedValue, height: fixedSize.height.fixedValue)
    }

    static func adapting(size: Size, to measure: Measure, remain: CGSize) {
//        let parentCGSize = usableSize(with: remain, margin: measure.margin)
//        let margin = measure.margin
//        let wrappedSize = CGSize(width: max(0, parentCGSize.width - margin.left - margin.right),
//                                 height: max(0, parentCGSize.height - margin.top - margin.bottom))

        let wrappedSize = usableSize(with: remain, margin: measure.margin)

        // 本身固有尺寸
        if size.isFixed() || size.isRatio() {
            let size = Caculator.caculate(size: size, by: wrappedSize)
            measure.py_size = CGSize(width: size.width.fixedValue, height: size.height.fixedValue)
        } else {
            if !size.width.isWrap {
                let width = Caculator.caculateFix(size.width, by: wrappedSize.width)
                measure.py_size.width = width.fixedValue
            }
            if !size.height.isWrap {
                let height = Caculator.caculateFix(size.height, by: wrappedSize.height)
                measure.py_size.height = height.fixedValue
            }
        }
    }

    static func remainSize(with size: CGSize, margin: UIEdgeInsets) -> CGSize {
        return CGSize(width: max(0, size.width + margin.left + margin.right),
                      height: max(0, size.height + margin.top + margin.bottom))
    }

    static func usableSize(with remain: CGSize, margin: UIEdgeInsets) -> CGSize {
        return CGSize(width: max(0, remain.width - margin.left - margin.right),
                      height: max(0, remain.height - margin.top - margin.bottom))
    }

    static func adaptingEstimateSize(measure: Measure, remain: CGSize) {
        var size = measure.py_size
        if !measure.size.width.isWrap {
            size.width = caculateFix(measure.size.width, by: remain.width - measure.margin.left - measure.margin.right).fixedValue
        }
        if !measure.size.height.isWrap {
            size.height = caculateFix(measure.size.height, by: remain.height - measure.margin.top - measure.margin.bottom).fixedValue
        }
        measure.py_size = size
    }
}

class NewCaculator {
    static func getChildRemainLength(_ sizeDesc: SizeDescription, currentRemain: CGFloat, totalPadding: CGFloat, totalRatio: CGFloat) -> CGFloat {
        if sizeDesc.isFixed {
            // 子布局剩余空间为固有尺寸 - 当前布局内边距
            return max(0, sizeDesc.fixedValue - totalPadding)
        } else if sizeDesc.isRatio {
            // 子布局剩余空间为
            return max(0, (sizeDesc.ratio / totalRatio) * currentRemain - totalPadding)
        } else if sizeDesc.isWrap {
            return max(sizeDesc.min, min(sizeDesc.max, currentRemain)) - totalPadding
        } else {
            fatalError()
        }
    }

    static func getChildRemainSize(_ size: Size, currentRemain: CGSize, padding: UIEdgeInsets, ratio: CGSize) -> CGSize {
        let width = getChildRemainLength(size.width, currentRemain: currentRemain.width, totalPadding: padding.getHorzTotal(), totalRatio: ratio.width)

        let height = getChildRemainLength(size.height, currentRemain: currentRemain.height, totalPadding: padding.getVertTotal(), totalRatio: ratio.height)

        return CGSize(width: width, height: height)
    }

    static func applyMeasure(_ measure: Measure, size: Size, in remain: CGSize, totalRatio: CGSize) {
        // 把size应用到measure上，只关心剩余空间
        let margin = measure.margin
        var finalSize = measure.py_size
        if !size.width.isWrap {
            finalSize.width = getNoneWrapLength(size.width, remain: remain.width, margin: margin.getHorzTotal(), ratio: totalRatio.width)
        }
        if !size.height.isWrap {
            finalSize.height = getNoneWrapLength(size.height, remain: remain.height, margin: margin.getVertTotal(), ratio: totalRatio.height)
        }
        measure.py_size = finalSize
    }

    private static func getNoneWrapLength(_ size: SizeDescription, remain: CGFloat, margin: CGFloat, ratio: CGFloat) -> CGFloat {
        if size.isFixed {
            return max(0, size.fixedValue)
        } else if size.isRatio {
            return max(0, (size.ratio / ratio) * (remain - margin))
        } else {
            fatalError()
        }
    }
}
