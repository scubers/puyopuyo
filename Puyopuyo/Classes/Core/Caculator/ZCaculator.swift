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
    lazy var regChildrenRemainSize: CGSize = {
        Caculator.getChildRemainSize(self.regulator.size,
                                        superRemain: self.remain,
                                        margin: self.regulator.margin,
                                        padding: self.regulator.padding,
                                        ratio: nil)
    }()

    func caculate() -> Size {
        var children = [Measure]()
        regulator.enumerateChild { _, m in
            if m.activated {
                children.append(m)
            }
        }

        var maxSizeWithSubMargin = CGSize.zero

        for measure in children {
            let subSize = _getEstimateSize(measure: measure, remain: regChildrenRemainSize)

            if subSize.width.isWrap || subSize.height.isWrap {
                fatalError()
            }
            
            Caculator.applyMeasure(measure, size: subSize, currentRemain: regChildrenRemainSize, ratio: .init(width: 1, height: 1))
            // 计算大小
            
            maxSizeWithSubMargin.width = max(maxSizeWithSubMargin.width, measure.py_size.width)
            maxSizeWithSubMargin.height = max(maxSizeWithSubMargin.height, measure.py_size.height)

        }
        
//        var calCenterSize = CGSize(width: regChildrenRemainSize.width + regFixedWidth, height: regChildrenRemainSize.height + regFixedHeight)
        var calCenterSize = regChildrenRemainSize
        if regulator.size.width.isWrap {
            calCenterSize.width = maxSizeWithSubMargin.width  + regFixedWidth + regulator.size.width.add
        }
        if regulator.size.height.isWrap {
            calCenterSize.height = maxSizeWithSubMargin.height + regFixedHeight + regulator.size.height.add
        }
        
        for measure in children {
            
            let subMargin = measure.margin
            // 计算中心
            var center = CGPoint(x: calCenterSize.width / 2 + regulator.padding.left, y: calCenterSize.height / 2 + regulator.padding.top)
            let alignment = measure.alignment
            let justifyContent = regulator.justifyContent

            // 水平方向
            let horzAlignment: Alignment = alignment.hasHorzAlignment() ? alignment : justifyContent
            // 垂直方向
            let vertAlignment: Alignment = alignment.hasVertAlignment() ? alignment : justifyContent

            if horzAlignment.contains(.left) {
                center.x = regulator.padding.left + subMargin.left + measure.py_size.width / 2
            } else if horzAlignment.contains(.right) {
                center.x = calCenterSize.width - (regulator.padding.right + subMargin.right + measure.py_size.width / 2)
            }

            if vertAlignment.contains(.top) {
                center.y = regulator.padding.top + subMargin.top + measure.py_size.height / 2
            } else if vertAlignment.contains(.bottom) {
                center.y = calCenterSize.height - (regulator.padding.bottom + subMargin.bottom + measure.py_size.height / 2)
            }

            measure.py_center = center
            
            if regulator.caculateChildrenImmediately {
                _ = measure.caculate(byParent: regulator, remain: regChildrenRemainSize)
            }
        }

        // 计算布局自身大小
        var width = regulator.size.width
        if width.isWrap {
            width = .fix(width.getWrapSize(by: maxSizeWithSubMargin.width + regulator.padding.left + regulator.padding.right))
        }

        var height = regulator.size.height
        if height.isWrap {
            height = .fix(height.getWrapSize(by: maxSizeWithSubMargin.height + regulator.padding.top + regulator.padding.bottom))
        }

        return Size(width: width, height: height)
    }

    private func _getEstimateSize(measure: Measure, remain: CGSize) -> Size {
        if measure.size.bothNotWrap() {
            return measure.size
        }
        return measure.caculate(byParent: regulator, remain: remain)
    }
}
