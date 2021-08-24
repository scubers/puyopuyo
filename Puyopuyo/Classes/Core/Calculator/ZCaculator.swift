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
        Calculator.getChildRemainSize(self.regulator.size,
                                     superRemain: self.remain,
                                     margin: self.regulator.margin,
                                     padding: self.regulator.padding,
                                     ratio: nil)
    }()

    var maxSizeWithSubMargin: CGSize = .zero

    func calculate() -> Size {
        var children = [Measure]()
        regulator.enumerateChild { _, measure in
            if measure.activated {
                children.append(measure)

                checkSizeConflict(measure)

                let subSize = _getEstimateSize(measure: measure, remain: regChildrenRemainSize)

                if subSize.width.isWrap || subSize.height.isWrap {
                    fatalError()
                }

                Calculator.applyMeasure(measure, size: subSize, currentRemain: regChildrenRemainSize, ratio: .init(width: 1, height: 1))
                // 计算大小

                maxSizeWithSubMargin.width = max(maxSizeWithSubMargin.width, measure.py_size.width + measure.margin.getHorzTotal())
                maxSizeWithSubMargin.height = max(maxSizeWithSubMargin.height, measure.py_size.height + measure.margin.getVertTotal())
            }
        }
        let containerSize = Calculator.getSize(regulator, currentRemain: remain, wrapContentSize: maxSizeWithSubMargin)

        for measure in children {
            // 计算中心
            measure.py_center = _calculateCenter(measure, containerSize: containerSize)
            if regulator.calculateChildrenImmediately {
                _ = measure.calculate(byParent: regulator, remain: regChildrenRemainSize)
            }
        }

        // 计算布局自身大小
        var width = regulator.size.width
        if width.isWrap {
            width = .fix(containerSize.width)
        }

        var height = regulator.size.height
        if height.isWrap {
            height = .fix(containerSize.height)
        }

        return Size(width: width, height: height)
    }

    private func _getWidthIfWrap() -> CGFloat? {
        if regulator.size.width.isWrap {
            return regulator.size.width.getWrapSize(by: maxSizeWithSubMargin.width + regulator.padding.left + regulator.padding.right)
        }
        return nil
    }

    private func _getHeightIfWrap() -> CGFloat? {
        if regulator.size.height.isWrap {
            return regulator.size.height.getWrapSize(by: maxSizeWithSubMargin.height + regulator.padding.top + regulator.padding.bottom)
        }
        return nil
    }

    private func checkSizeConflict(_ measure: Measure) {
        #if DEBUG
        if regulator.size.width.isWrap && measure.size.width.isRatio {
            Calculator.constraintConflict(crash: false, "[\(regulator.getRealTarget())] - [\(measure.getRealTarget())] - width (p: wrap, c: ratio) conflict !!!!")
        }
        if regulator.size.height.isWrap && measure.size.height.isRatio {
            Calculator.constraintConflict(crash: false, "[\(regulator.getRealTarget())] - [\(measure.getRealTarget())] - height (p: wrap, c: ratio) conflict !!!!")
        }
        #endif
    }

    private func _calculateCenter(_ measure: Measure, containerSize: CGSize) -> CGPoint {
        let x = Calculator.calculateCrossAlignmentOffset(measure, direction: .y, justifyContent: regulator.justifyContent, parentPadding: regulator.padding, parentSize: containerSize)
        let y = Calculator.calculateCrossAlignmentOffset(measure, direction: .x, justifyContent: regulator.justifyContent, parentPadding: regulator.padding, parentSize: containerSize)
        return CGPoint(x: x, y: y)
    }

    private func _getEstimateSize(measure: Measure, remain: CGSize) -> Size {
        if measure.size.bothNotWrap() {
            return measure.size
        }
        return measure.calculate(byParent: regulator, remain: remain)
    }
}
