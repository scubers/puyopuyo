//
//  ZLayoutCaculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

class ZCalculator: Calculator {
    func calculate(_ measure: Measure, layoutResidual: CGSize) -> CGSize {
        _ZCalculator(measure as! ZRegulator, layoutResidual: layoutResidual).calculate()
    }
}

private class _ZCalculator {
    let regulator: ZRegulator
    let layoutResidual: CGSize
    let contentResidual: CGSize
    let childrenLayoutResidual: CGSize
    init(_ regulator: ZRegulator, layoutResidual: CGSize) {
        self.regulator = regulator
        self.layoutResidual = layoutResidual
        self.contentResidual = CalculateUtil.getContentResidual(layoutResidual: layoutResidual, margin: regulator.margin, size: regulator.size)
        self.childrenLayoutResidual = CalculateUtil.getChildrenLayoutResidual(for: regulator, regulatorLayoutResidual: layoutResidual)
    }

    lazy var regFixedWidth: CGFloat = regulator.padding.left + regulator.padding.right
    lazy var regFixedHeight: CGFloat = regulator.padding.top + regulator.padding.bottom

    var maxChildContentSize: CGSize = .zero

    var calculateChildren = [Measure]()

    lazy var maybeRatioChildren = [Measure]()

    func calculate() -> CGSize {
        prepareData()

        calculateChildrenSize()

        handleRatioChildrenIfNeeded()

        let intrinsicSize = CalculateUtil.getWrappedContentSize(for: regulator, padding: regulator.padding, contentResidual: contentResidual, childrenContentSize: maxChildContentSize)

        calculateChildrenCenter(intrinsic: intrinsicSize)

        return intrinsicSize
    }

    private func prepareData() {
        regulator.enumerateChildren { m in
            if !m.activated { return }

            calculateChildren.append(m)

            if m.size.maybeRatio() {
                maybeRatioChildren.append(m)
            }

            // 校验最大固有尺寸
            if m.size.width.isFixed {
                maxChildContentSize.width = max(maxChildContentSize.width, m.size.width.fixedValue + m.margin.getHorzTotal())
            }

            if m.size.height.isFixed {
                maxChildContentSize.height = max(maxChildContentSize.height, m.size.height.fixedValue + m.margin.getVertTotal())
            }
        }
    }

    private func calculateChildrenSize() {
        calculateChildren.forEach { m in
            let childLayoutResidual = getLayoutResidual(forChild: m)
            _calculateChild(m, childLayoutResidual: childLayoutResidual, msg: "ZCalculator first time calculating")
        }
    }

    private func handleRatioChildrenIfNeeded() {
        // 当布局包裹时，需要最后拉伸子填充节点
        if regulator.size.maybeWrap() {
            maybeRatioChildren.forEach { m in
                let currentChildResidual = getLayoutResidual(forChild: m)
                _calculateChild(m, childLayoutResidual: currentChildResidual, msg: "ZCalculator ratio fill up calculating")
            }
        }
    }

    private func _calculateChild(_ measure: Measure, childLayoutResidual: CGSize, msg: String) {
        measure.calculatedSize = CalHelper.calculateIntrinsicSize(for: measure, layoutResidual: childLayoutResidual, strategy: .lazy)

        // 记录当前最大宽高
        appendMaxWidthIfNeeded(measure)
        appendMaxHeightIfNeeded(measure)
    }

    private func calculateChildrenCenter(intrinsic: CGSize) {
        for measure in calculateChildren {
            // 计算中心
            measure.calculatedCenter = _calculateCenter(measure, containerSize: intrinsic)
        }
    }

    private func resetMaxContentSize() {
        maxChildContentSize = .zero
        calculateChildren.forEach { m in
            appendMaxWidthIfNeeded(m)
            appendMaxHeightIfNeeded(m)
        }
    }

    private func appendMaxWidthIfNeeded(_ measure: Measure) {
        if !measure.size.width.isRatio {
            maxChildContentSize.width = max(maxChildContentSize.width, measure.calculatedSize.width + measure.margin.getHorzTotal())
        }
    }

    private func appendMaxHeightIfNeeded(_ measure: Measure) {
        if !measure.size.height.isRatio {
            maxChildContentSize.height = max(maxChildContentSize.height, measure.calculatedSize.height + measure.margin.getVertTotal())
        }
    }

    private func _calculateCenter(_ measure: Measure, containerSize: CGSize) -> CGPoint {
        let x = CalculateUtil.getCalculatedChildCrossAlignmentOffset(measure, direction: .y, justifyContent: regulator.justifyContent, parentPadding: regulator.padding, parentSize: containerSize)
        let y = CalculateUtil.getCalculatedChildCrossAlignmentOffset(measure, direction: .x, justifyContent: regulator.justifyContent, parentPadding: regulator.padding, parentSize: containerSize)
        return CGPoint(x: x, y: y)
    }

    private func getLayoutResidual(forChild child: Measure) -> CGSize {
        var residual: CGSize = childrenLayoutResidual

        if regulator.size.width.isWrap, child.size.width.isRatio {
            residual.width = maxChildContentSize.width
        }
        if regulator.size.height.isWrap, child.size.height.isRatio {
            residual.height = maxChildContentSize.height
        }
        // 下面的注释代码允许 .ratio != 1 的情况跟随比例变化
        if child.size.width.isRatio {
            residual.width = (residual.width) * child.size.width.ratio
        }
        if child.size.height.isRatio {
            residual.height = (residual.height) * child.size.height.ratio
        }
        return residual
    }
}
