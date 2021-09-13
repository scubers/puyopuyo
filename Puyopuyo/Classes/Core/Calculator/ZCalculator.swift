//
//  ZLayoutCaculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

class ZCalculator {
    let regulator: ZRegulator
    let residual: CGSize
    init(_ regulator: ZRegulator, residual: CGSize) {
        self.regulator = regulator
        self.residual = residual
    }

    lazy var regFixedWidth: CGFloat = regulator.padding.left + regulator.padding.right
    lazy var regFixedHeight: CGFloat = regulator.padding.top + regulator.padding.bottom
    lazy var regChildrenResidualSize: CGSize = {
        Calculator.getChildResidualSize(regulator.size,
                                        residual: residual,
                                        margin: regulator.margin,
                                        padding: regulator.padding)
    }()

    var maxChildSizeWithSubMargin: CGSize = .zero

    var calculateChildren = [Measure]()

    lazy var maybeRatioChildren = [Measure]()

    func calculate() -> CGSize {
        regulator.py_enumerateChild { measure in
            if measure.activated {
                calculateChildren.append(measure)
                let currentChildResidual = _getCurrentChildResidualSize(measure)
                _calculateChild(measure, residual: currentChildResidual)

                if measure.size.maybeRatio() {
                    maybeRatioChildren.append(measure)
                }
            }
        }

        // 当布局包裹时，需要最后拉伸子填充节点
        if regulator.size.maybeWrap() {
            maybeRatioChildren.forEach { m in
                let currentChildResidual = _getCurrentChildResidualSize(m)
                _calculateChild(m, residual: currentChildResidual)
            }
        }

        let containerSize = Calculator.getRegulatorIntrinsicSize(regulator, residual: residual, contentSize: maxChildSizeWithSubMargin)

        for measure in calculateChildren {
            // 计算中心
            measure.py_center = _calculateCenter(measure, containerSize: containerSize)
        }

        return containerSize
    }

    private func _calculateChild(_ measure: Measure, residual: CGSize) {
        var intrinsicSize: CGSize
        if regulator.calculateChildrenImmediately || measure.size.maybeWrap() {
            intrinsicSize = measure.calculate(by: residual)
        } else {
            intrinsicSize = Calculator.getIntrinsicSize(margin: measure.margin, residual: residual, size: measure.size)
        }
        measure.py_size = intrinsicSize

        let margin = measure.margin

        // 记录当前最大宽高
        maxChildSizeWithSubMargin.width = max(maxChildSizeWithSubMargin.width, intrinsicSize.width + margin.getHorzTotal())
        maxChildSizeWithSubMargin.height = max(maxChildSizeWithSubMargin.height, intrinsicSize.height + margin.getVertTotal())
    }

    private func _calculateCenter(_ measure: Measure, containerSize: CGSize) -> CGPoint {
        let x = Calculator.calculateCrossAlignmentOffset(measure, direction: .y, justifyContent: regulator.justifyContent, parentPadding: regulator.padding, parentSize: containerSize)
        let y = Calculator.calculateCrossAlignmentOffset(measure, direction: .x, justifyContent: regulator.justifyContent, parentPadding: regulator.padding, parentSize: containerSize)
        return CGPoint(x: x, y: y)
    }

    private func _getCurrentChildResidualSize(_ measure: Measure) -> CGSize {
        var residual = regChildrenResidualSize
        if regulator.size.width.isWrap, measure.size.width.isRatio {
            residual.width = maxChildSizeWithSubMargin.width
        }
        if regulator.size.height.isWrap, measure.size.height.isRatio {
            residual.height = maxChildSizeWithSubMargin.height
        }
        return residual
    }
}
