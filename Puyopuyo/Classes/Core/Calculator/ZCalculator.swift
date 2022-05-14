//
//  ZLayoutCaculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

struct ZCalculator: Calculator {
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

    var maxChildContentSize: CGSize = .zero

    var calculateChildren = [Measure]()

    lazy var maybeRatioChildren = [Measure]()

    func calculate() -> CGSize {
        prepareData()

        calculateChildrenSize()

        handleRatioChildrenIfNeeded()

        let intrinsicSize = getIntrinsicSize()

        calculateChildrenCenter(intrinsic: intrinsicSize)

        return intrinsicSize
    }

    private func getIntrinsicSize() -> CGSize {
        if regulator.size.bothNotWrap {
            return CalHelper.getEstimateIntrinsic(for: regulator, layoutResidual: layoutResidual)
        }
        return CalculateUtil.getWrappedContentSize(for: regulator, padding: regulator.padding, contentResidual: contentResidual, childrenContentSize: maxChildContentSize)
    }

    private func prepareData() {
        calculateChildren.reserveCapacity(regulator.children.count)

        regulator.enumerateChildren { m in
            if !m.activated { return }

            calculateChildren.append(m)

            if m.size.maybeRatio {
                maybeRatioChildren.append(m)
            }

            // 校验最大固有尺寸
            if m.size.width.isFixed {
                maxChildContentSize.width = Swift.max(maxChildContentSize.width, m.size.width.fixedValue + m.margin.getHorzTotal())
            }

            if m.size.height.isFixed {
                maxChildContentSize.height = Swift.max(maxChildContentSize.height, m.size.height.fixedValue + m.margin.getVertTotal())
            }
        }
    }

    private func calculateChildrenSize() {
        calculateChildren.forEach { m in
            _calculateChild(m, msg: "ZCalculator first time calculating")
        }
    }

    private func handleRatioChildrenIfNeeded() {
        // 当布局包裹时，需要最后拉伸子填充节点
        if regulator.size.maybeWrap {
            maybeRatioChildren.forEach { m in
                _calculateChild(m, msg: "ZCalculator ratio fill up calculating")
            }
        }
    }

    private func _calculateChild(_ measure: Measure, msg: String) {
        let childLayoutResidual = getLayoutResidual(forChild: measure)

        measure.calculatedSize = CalHelper.calculateIntrinsicSize(for: measure, layoutResidual: childLayoutResidual, strategy: measure.isLayoutEntryPoint ? .estimate : .calculate)

        // 记录当前最大宽高
        appendMaxWidthIfNeeded(measure)
        appendMaxHeightIfNeeded(measure)
    }

    private func calculateChildrenCenter(intrinsic: CGSize) {
        calculateChildren.forEach { measure in
            // 计算中心
            measure.calculatedCenter = _calculateCenter(measure, containerSize: intrinsic)
        }
    }

    private func appendMaxWidthIfNeeded(_ measure: Measure) {
        if !measure.size.width.isRatio {
            maxChildContentSize.width.replaceIfLarger(measure.calculatedSizeWithMargin.width)
        }
    }

    private func appendMaxHeightIfNeeded(_ measure: Measure) {
        if !measure.size.height.isRatio {
            maxChildContentSize.height.replaceIfLarger(measure.calculatedSizeWithMargin.height)
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
