//
//  ZLayoutCaculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

class ZCaculator {
    let regulator: ZRegulator
    let parent: Measure
    let remain: CGSize
    init(_ regulator: ZRegulator, parent: Measure, remain: CGSize) {
        self.regulator = regulator
        self.parent = parent
        self.remain = remain
    }

    lazy var regFixedWidth: CGFloat = self.regulator.padding.left + self.regulator.padding.right
    lazy var regFixedHeight: CGFloat = self.regulator.padding.top + self.regulator.padding.bottom
    lazy var layoutFixedSize = self.regulator.py_size
//    lazy var layoutCalPadding = CalEdges(insets: layout.padding, direction: layout.direction)
//    lazy var layoutCalFixedSize = CalFixedSize(cgSize: layout.target?.py_size ?? .zero, direction: layout.direction)
//    lazy var layoutCalSize = CalSize(size: layout.size, direction: layout.direction)
//    lazy var totalFixedMain: CGFloat = self.layoutCalPadding.start + self.layoutCalPadding.end

    func caculate() -> Size {
        if !(parent is Regulator) {
            Caculator.adaptingEstimateSize(measure: regulator, remain: remain)
        }

//        let layoutFixedSize = regulator.py_size

        var children = [Measure]()
        regulator.enumerateChild { _, m in
            if m.activated {
                children.append(m)
            }
        }

        var maxSizeWithMargin = CGSize.zero

        for measure in children {
//            let subSize = measure.caculate(byParent: regulator)
            let subSize = _getEstimateSize(measure: measure, remain: getCurrentRemainForChildren())
            let subMargin = measure.margin

            if subSize.width.isWrap || subSize.height.isWrap {
                fatalError()
            }
            let zContainerSize = CGSize(width: max(layoutFixedSize.width - regFixedWidth - (subMargin.left + subMargin.right), 0),
                                        height: max(layoutFixedSize.height - regFixedHeight - (subMargin.top + subMargin.bottom), 0))
            // 计算大小
            let sizeAfterCaculate = Caculator.caculate(size: subSize, by: zContainerSize)
            measure.py_size = CGSize(width: sizeAfterCaculate.width.fixedValue, height: sizeAfterCaculate.height.fixedValue)
            maxSizeWithMargin.width = max(maxSizeWithMargin.width, sizeAfterCaculate.width.fixedValue + subMargin.left + subMargin.right)
            maxSizeWithMargin.height = max(maxSizeWithMargin.height, sizeAfterCaculate.height.fixedValue + subMargin.top + subMargin.bottom)

            // 计算中心
            var center = CGPoint(x: layoutFixedSize.width / 2, y: layoutFixedSize.height / 2)
            let alignment = measure.alignment
            let justifyContent = regulator.justifyContent

            // 水平方向
            let horzAlignment: Alignment = alignment.hasHorzAlignment() ? alignment : justifyContent
            // 垂直方向
            let vertAlignment: Alignment = alignment.hasVertAlignment() ? alignment : justifyContent

            if horzAlignment.contains(.left) {
                center.x = regulator.padding.left + subMargin.left + sizeAfterCaculate.width.fixedValue / 2
            } else if horzAlignment.contains(.right) {
                center.x = layoutFixedSize.width - (regulator.padding.right + subMargin.right + sizeAfterCaculate.width.fixedValue / 2)
            }

            if vertAlignment.contains(.top) {
                center.y = regulator.padding.top + subMargin.top + sizeAfterCaculate.height.fixedValue / 2
            } else if vertAlignment.contains(.bottom) {
                center.y = layoutFixedSize.height - (regulator.padding.bottom + subMargin.bottom + sizeAfterCaculate.height.fixedValue / 2)
            }

            measure.py_center = center

            if regulator.caculateChildrenImmediately {
                _ = measure.caculate(byParent: regulator, remain: Caculator.remainSize(with: measure.py_size, margin: measure.margin))
            }
        }

        // 计算布局自身大小
        var width = regulator.size.width
        if width.isWrap {
            width = .fix(width.getWrapSize(by: maxSizeWithMargin.width + regulator.padding.left + regulator.padding.right))
        }

        var height = regulator.size.height
        if height.isWrap {
            height = .fix(height.getWrapSize(by: maxSizeWithMargin.height + regulator.padding.top + regulator.padding.bottom))
        }

        return Size(width: width, height: height)
    }

    private func _getEstimateSize(measure: Measure, remain: CGSize) -> Size {
//        if measure.size.maybeWrap() {
//            return measure.caculate(byParent: regulator, remain: remain)
//        }
//        return measure.size
        
        if measure.size.bothNotWrap() {
            return measure.size
        }
           
        let calSize = measure.size
        var finalSize = calSize
        let originSize = measure.py_size

        if calSize.width.isRatio {
            finalSize.width = .fix(calSize.width.getFixValue(relay: remain.width, totalRatio: 1, ratioFill: false))
        }
           
        if calSize.height.isRatio {
            finalSize.height = .fix(calSize.height.getFixValue(relay: remain.height, totalRatio: 1, ratioFill: false))
        }
           
        if measure.size.maybeWrap() {
            // 需要往下级计算
            var width: CGFloat = originSize.width
            var height: CGFloat = originSize.height
            if !calSize.width.isWrap {
                width = finalSize.width.fixedValue
            }
            if !calSize.height.isWrap {
                height = finalSize.height.fixedValue
            }
//            measure.py_size = CalFixedSize(main: main, cross: cross, direction: regulator.direction).getSize()
            measure.py_size = CGSize(width: width, height: height)
            
            return measure.caculate(byParent: regulator, remain: remain)
        }
        return finalSize
    }

    private func getCurrentRemainForChildren() -> CGSize {
        var size = CGSize(width: max(0, layoutFixedSize.width - regFixedWidth),
                          height: max(0, layoutFixedSize.height - regFixedHeight))
        if regulator.size.width.isWrap {
            size.width = .greatestFiniteMagnitude
        }
        if regulator.size.height.isWrap {
            size.height = .greatestFiniteMagnitude
        }
        return size
    }
}
