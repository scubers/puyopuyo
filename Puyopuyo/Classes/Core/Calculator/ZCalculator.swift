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
        Calculator.getChildrenTotalResidul(for: regulator, regulatorResidual: residual)
    }()

    var maxContentSize: CGSize = .zero

    var calculateChildren = [Measure]()

    lazy var maybeRatioChildren = [Measure]()

    func calculate() -> CGSize {
        prepareData()

        calculateChildrenSize()

        handleRatioChildrenIfNeeded()

        let intrinsicSize = Calculator.getRegulatorIntrinsicSize(regulator, residual: residual, contentSize: maxContentSize)

        calculateChildrenCenter(intrinsic: intrinsicSize)

        return intrinsicSize
    }

    private func prepareData() {
        regulator.py_enumerateChild { m in
            if !m.activated { return }

            calculateChildren.append(m)

            if m.size.maybeRatio() {
                maybeRatioChildren.append(m)
            }

            // 校验最大固有尺寸
            if m.size.width.isFixed {
                maxContentSize.width = max(maxContentSize.width, m.size.width.fixedValue + m.margin.getHorzTotal())
            }

            if m.size.height.isFixed {
                maxContentSize.height = max(maxContentSize.height, m.size.height.fixedValue + m.margin.getVertTotal())
            }
        }
    }

    private func calculateChildrenSize() {
        calculateChildren.forEach { m in
            let subResidual = _getCurrentChildResidualSize(m)
            _calculateChild(m, residual: subResidual)
        }
    }

    private func handleRatioChildrenIfNeeded() {
        // 当布局包裹时，需要最后拉伸子填充节点
        if regulator.size.maybeWrap() {
            maybeRatioChildren.forEach { m in
                let currentChildResidual = _getCurrentChildResidualSize(m)
                _calculateChild(m, residual: currentChildResidual)
            }
        }
    }

    private func _calculateChild(_ measure: Measure, residual: CGSize) {
        measure.py_size = Calculator.calculateIntrinsicSize(for: measure, residual: residual, calculateChildrenImmediately: regulator.calculateChildrenImmediately)

        // 记录当前最大宽高
        appendMaxWidthIfNeeded(measure)
        appendMaxHeightIfNeeded(measure)
    }

    private func calculateChildrenCenter(intrinsic: CGSize) {
        for measure in calculateChildren {
            // 计算中心
            measure.py_center = _calculateCenter(measure, containerSize: intrinsic)
        }
    }

    private func resetMaxContentSize() {
        maxContentSize = .zero
        calculateChildren.forEach { m in
            appendMaxWidthIfNeeded(m)
            appendMaxHeightIfNeeded(m)
        }
    }

    private func appendMaxWidthIfNeeded(_ measure: Measure) {
        if !measure.size.width.isRatio {
            maxContentSize.width = max(maxContentSize.width, measure.py_size.width + measure.margin.getHorzTotal())
        }
    }

    private func appendMaxHeightIfNeeded(_ measure: Measure) {
        if !measure.size.height.isRatio {
            maxContentSize.height = max(maxContentSize.height, measure.py_size.height + measure.margin.getVertTotal())
        }
    }

    private func _calculateCenter(_ measure: Measure, containerSize: CGSize) -> CGPoint {
        let x = Calculator.calculateCrossAlignmentOffset(measure, direction: .y, justifyContent: regulator.justifyContent, parentPadding: regulator.padding, parentSize: containerSize)
        let y = Calculator.calculateCrossAlignmentOffset(measure, direction: .x, justifyContent: regulator.justifyContent, parentPadding: regulator.padding, parentSize: containerSize)
        return CGPoint(x: x, y: y)
    }

    private func _getCurrentChildResidualSize(_ measure: Measure) -> CGSize {
        var residual: CGSize = regChildrenResidualSize

        if regulator.size.width.isWrap, measure.size.width.isRatio {
            residual.width = maxContentSize.width
        }
        if regulator.size.height.isWrap, measure.size.height.isRatio {
            residual.height = maxContentSize.height
        }
        // 下面的注释代码允许 .ratio != 1 的情况跟随比例变化
        if measure.size.width.isRatio {
            residual.width = (residual.width) * measure.size.width.ratio
        }
        if measure.size.height.isRatio {
            residual.height = (residual.height) * measure.size.height.ratio
        }
        return residual
    }
}
