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
        regulator.enumerateChild { _, measure in
            if measure.activated {
                children.append(measure)

                checkSizeConflict(measure)

                let subSize = _getEstimateSize(measure: measure, remain: regChildrenRemainSize)

                if subSize.width.isWrap || subSize.height.isWrap {
                    fatalError()
                }

                Caculator.applyMeasure(measure, size: subSize, currentRemain: regChildrenRemainSize, ratio: .init(width: 1, height: 1))
                // 计算大小

                maxSizeWithSubMargin.width = max(maxSizeWithSubMargin.width, measure.py_size.width + measure.margin.getHorzTotal())
                maxSizeWithSubMargin.height = max(maxSizeWithSubMargin.height, measure.py_size.height + measure.margin.getVertTotal())
            }
        }

        var containerSize = regChildrenRemainSize
        if regulator.size.width.isWrap {
            containerSize.width = regulator.size.width.getWrapSize(by: maxSizeWithSubMargin.width + regulator.padding.left + regulator.padding.right)
        }
        if regulator.size.height.isWrap {
            containerSize.height = regulator.size.height.getWrapSize(by: maxSizeWithSubMargin.height + regulator.padding.top + regulator.padding.bottom)
        }

        for measure in children {
            // 计算中心
            measure.py_center = _caculateCenter(measure, containerSize: containerSize)
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

    private func checkSizeConflict(_ measure: Measure) {
        #if DEBUG
        if regulator.size.width.isWrap && measure.size.width.isRatio {
            Caculator.constraintConflict(crash: false, "[\(regulator.getRealTarget())] - [\(measure.getRealTarget())] - width (p: wrap, c: ratio) conflict !!!!")
        }
        if regulator.size.height.isWrap && measure.size.height.isRatio {
            Caculator.constraintConflict(crash: false, "[\(regulator.getRealTarget())] - [\(measure.getRealTarget())] - height (p: wrap, c: ratio) conflict !!!!")
        }
        #endif
    }

    private func _caculateCenter(_ measure: Measure, containerSize: CGSize) -> CGPoint {
        let x = Caculator.caculateCrossAlignmentOffset(measure, direction: .y, justifyContent: regulator.justifyContent, parentPadding: regulator.padding, parentSize: containerSize)
        let y = Caculator.caculateCrossAlignmentOffset(measure, direction: .x, justifyContent: regulator.justifyContent, parentPadding: regulator.padding, parentSize: containerSize)
        return CGPoint(x: x, y: y)
    }

    private func _getEstimateSize(measure: Measure, remain: CGSize) -> Size {
        if measure.size.bothNotWrap() {
            return measure.size
        }
        return measure.caculate(byParent: regulator, remain: remain)
    }
}
