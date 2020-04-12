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

    var maxSizeWithSubMargin: CGSize = .zero

    func caculate() -> Size {
        var children = [Measure]()
        regulator.enumerateChild { _, m in
            if m.activated {
                children.append(m)
            }
        }

        for measure in children {
            let subSize = _getEstimateSize(measure: measure, remain: regChildrenRemainSize)

            if subSize.width.isWrap || subSize.height.isWrap {
                fatalError()
            }

            Caculator.applyMeasure(measure, size: subSize, currentRemain: regChildrenRemainSize, ratio: .init(width: 1, height: 1))
            // 计算大小

            maxSizeWithSubMargin.width = max(maxSizeWithSubMargin.width, measure.py_size.width + measure.margin.getHorzTotal())
            maxSizeWithSubMargin.height = max(maxSizeWithSubMargin.height, measure.py_size.height + measure.margin.getVertTotal())
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

        var calCenterSize = regulator.py_size
//        if regulator.size.width.isWrap {
//            calCenterSize.width = max(0, regulator.py_size.width - regFixedWidth)
//        }
//        if regulator.size.height.isWrap {
//            calCenterSize.height = max(0, regulator.py_size.height - regFixedHeight)
//        }

        for measure in children {
//            let subMargin = measure.margin
//            // 计算中心
//            var center = CGPoint(x: (calCenterSize.width / 2 + regulator.padding.left) * measure.widthAligmentRatio,
//                                 y: (calCenterSize.height / 2 + regulator.padding.top) * measure.heightAligmentRatio)
//            let alignment = measure.alignment
//            let justifyContent = regulator.justifyContent
//
//            // 水平方向
//            let horzAlignment: Alignment = alignment.hasHorzAlignment() ? alignment : justifyContent
//            // 垂直方向
//            let vertAlignment: Alignment = alignment.hasVertAlignment() ? alignment : justifyContent
//
//            if horzAlignment.contains(.left) {
//                center.x = regulator.padding.left + subMargin.left + measure.py_size.width / 2
//            } else if horzAlignment.contains(.right) {
//                center.x = calCenterSize.width - (regulator.padding.right + subMargin.right + measure.py_size.width / 2)
//            }
//
//            if vertAlignment.contains(.top) {
//                center.y = regulator.padding.top + subMargin.top + measure.py_size.height / 2
//            } else if vertAlignment.contains(.bottom) {
//                center.y = calCenterSize.height - (regulator.padding.bottom + subMargin.bottom + measure.py_size.height / 2)
//            }
//            measure.py_center = center
            
            measure.py_center = _caculateCenter(measure, containerSize: calCenterSize)


            if regulator.caculateChildrenImmediately {
                _ = measure.caculate(byParent: regulator, remain: regChildrenRemainSize)
            }
        }

        return Size(width: width, height: height)
    }

    private func _caculateCenter(_ measure: Measure, containerSize: CGSize) -> CGPoint {
        let x = _caculateCrossAligment(measure, direction: .y, containerSize: containerSize)
        let y = _caculateCrossAligment(measure, direction: .x, containerSize: containerSize)
        return CGPoint(x: x, y: y)
    }

    private func _caculateCrossAligment(_ measure: Measure, direction: Direction, containerSize: CGSize) -> CGFloat {
        let calSize = containerSize.getCalFixedSize(by: direction)
        let calPadding = regulator.padding.getCalEdges(by: direction)

        let subMargin = measure.margin.getCalEdges(by: direction)
        let subFixedSize = measure.py_size.getCalFixedSize(by: direction)

        let crossAligmentRatio = direction == .x ? measure.heightAligmentRatio : measure.widthAligmentRatio

        let subCrossAligment: Alignment = measure.alignment.hasCrossAligment(for: direction) ? measure.alignment : regulator.justifyContent

        var position = ((calSize.cross - calPadding.crossFixed) / 2 + calPadding.forward) * crossAligmentRatio

        if subCrossAligment.isForward(for: direction) {
            position = calPadding.forward + subMargin.forward + subFixedSize.cross / 2
        } else if subCrossAligment.isBackward(for: direction) {
            position = calSize.cross - (calPadding.backward + subMargin.backward + subFixedSize.cross / 2)
        }

        return position
    }

    private func _getEstimateSize(measure: Measure, remain: CGSize) -> Size {
        if measure.size.bothNotWrap() {
            return measure.size
        }
        return measure.caculate(byParent: regulator, remain: remain)
    }
}
