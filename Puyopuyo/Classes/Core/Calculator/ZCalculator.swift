//
//  ZLayoutCaculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

class ZCalculator {
    let regulator: ZRegulator
    let remain: CGSize
    init(_ regulator: ZRegulator, remain: CGSize) {
        self.regulator = regulator
        self.remain = remain
    }

    lazy var regFixedWidth: CGFloat = regulator.padding.left + regulator.padding.right
    lazy var regFixedHeight: CGFloat = regulator.padding.top + regulator.padding.bottom
    lazy var regChildrenRemainSize: CGSize = {
        Calculator.getChildRemainSize(regulator.size,
                                      superRemain: remain,
                                      margin: regulator.margin,
                                      padding: regulator.padding,
                                      ratio: nil)
    }()

    var maxChildSizeWithSubMargin: CGSize = .zero

    var calculateChildren = [Measure]()

    lazy var maybeRatioChildren = [Measure]()

    func calculate() -> Size {
        regulator.py_enumerateChild { measure in
            if measure.activated {
                calculateChildren.append(measure)
                let currentChildRemain = _getCurrentChildRemainSize(measure)
                _calculateChild(measure, remain: currentChildRemain)

                if measure.size.maybeRatio() {
                    maybeRatioChildren.append(measure)
                }
            }
        }

        // 当布局包裹时，需要最后拉伸子填充节点
        if regulator.size.maybeWrap() {
            maybeRatioChildren.forEach { m in
                let currentChildRemain = _getCurrentChildRemainSize(m)
                _calculateChild(m, remain: currentChildRemain)
            }
        }

        let containerSize = Calculator.getSize(regulator, currentRemain: remain, wrapContentSize: maxChildSizeWithSubMargin)

        for measure in calculateChildren {
            // 计算中心
            measure.py_center = _calculateCenter(measure, containerSize: containerSize)
            if regulator.calculateChildrenImmediately {
                _ = measure.calculate(remain: regChildrenRemainSize)
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

    private func _calculateChild(_ measure: Measure, remain: CGSize) {
        let subSize = _getEstimateSize(measure: measure, remain: remain)

        // 计算 & 应用 大小
        Calculator.applyMeasure(measure, size: subSize, currentRemain: remain, ratio: .init(width: 1, height: 1))

        // 记录当前最大宽高
        maxChildSizeWithSubMargin.width = max(maxChildSizeWithSubMargin.width, measure.py_size.width + measure.margin.getHorzTotal())
        maxChildSizeWithSubMargin.height = max(maxChildSizeWithSubMargin.height, measure.py_size.height + measure.margin.getVertTotal())
    }

    private func _calculateCenter(_ measure: Measure, containerSize: CGSize) -> CGPoint {
        let x = Calculator.calculateCrossAlignmentOffset(measure, direction: .y, justifyContent: regulator.justifyContent, parentPadding: regulator.padding, parentSize: containerSize)
        let y = Calculator.calculateCrossAlignmentOffset(measure, direction: .x, justifyContent: regulator.justifyContent, parentPadding: regulator.padding, parentSize: containerSize)
        return CGPoint(x: x, y: y)
    }

    private func _getEstimateSize(measure: Measure, remain: CGSize) -> Size {
        var size: Size
        if measure.size.bothNotWrap() {
            size = measure.size
        }
        size = measure.calculate(remain: remain)
        if size.maybeWrap() {
            fatalError()
        }
        return size
    }

    private func _getCurrentChildRemainSize(_ measure: Measure) -> CGSize {
        var remain = regChildrenRemainSize
        if regulator.size.width.isWrap, measure.size.width.isRatio {
            remain.width = maxChildSizeWithSubMargin.width
        }
        if regulator.size.height.isWrap, measure.size.height.isRatio {
            remain.height = maxChildSizeWithSubMargin.height
        }
        return remain
    }
}
