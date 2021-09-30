//
//  FlowCalculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/8/20.
//

import Foundation

class FlowCalculator {
    init(_ regulator: FlowRegulator, residual: CGSize) {
        self.regulator = regulator
        self.residual = residual
    }

    let regulator: FlowRegulator
    let residual: CGSize
    var arrange: Int { regulator.arrange }

    var regDirection: Direction { regulator.direction }

    lazy var regChildrenResidualCalSize: CalFixedSize = {
        let size = Calculator.getChildrenTotalResidul(for: regulator, regulatorResidual: residual)
        return CalFixedSize(cgSize: size, direction: regDirection)
    }()

    var regCalPadding: CalEdges { CalEdges(insets: regulator.padding, direction: regDirection) }
    var regCalSize: CalSize { CalSize(size: regulator.size, direction: regDirection) }

    func calculate() -> CGSize {
        var calculateChildren = [Measure]()
        regulator.enumerateChild { m in
            if m.activated {
                calculateChildren.append(m)
            }
        }
        if regulator.arrange > 0 {
            return _calculateByFixedCount(available: calculateChildren)
        }
        return _calculateByContent(available: calculateChildren)
    }

    private func _calculateByContent(available children: [Measure]) -> CGSize {
        var virtualLines = [VirtualLinearRegulator]()

        var currentLine = [Measure]()
        var maxCross: CGFloat = 0
        let totalCross = regChildrenResidualCalSize.cross

        children.forEach { m in
            let subCalSize = m.size.getCalSize(by: regDirection)
            let subCalFixedSize = Calculator.calculateIntrinsicSize(for: m, residual: regChildrenResidualCalSize.getSize(), calculateChildrenImmediately: false, diagnosisMessage: "FlowCalculator content test calculating").getCalFixedSize(by: regDirection)
            let subCalMargin = CalEdges(insets: m.margin, direction: regDirection)

            let space = CGFloat(min(1, currentLine.count)) * regulator.itemSpace
            // 计算当前累计的最大cross
            if subCalSize.cross.isRatio, maxCross + space + subCalMargin.crossFixed < totalCross {
                // 还有剩余空间
                maxCross = totalCross
            } else {
                maxCross += (subCalFixedSize.cross + space + subCalMargin.crossFixed)
            }

            if maxCross > totalCross { // 内容超出
                if currentLine.isEmpty {
                    virtualLines.append(getVirtualLine(children: [m], index: virtualLines.count))
                } else {
                    // 之前的行先归档
                    virtualLines.append(getVirtualLine(children: currentLine, index: virtualLines.count))
                    maxCross = subCalFixedSize.cross + subCalMargin.crossFixed
                    // 另起新的一行
                    currentLine = [m]
                }
            } else { // 内容未超出
                currentLine.append(m)
            }
            // 主动换行
            if m.flowEnding {
                virtualLines.append(getVirtualLine(children: currentLine, index: virtualLines.count))
                currentLine = []
                maxCross = 0
            }
        }
        if !currentLine.isEmpty {
            virtualLines.append(getVirtualLine(children: currentLine, index: virtualLines.count))
        }
        let size = getVirtualRegulator(children: virtualLines).calculate(by: residual)
        virtualLines.forEach { $0.justifyChildrenWithCenter() }
        return size
    }

    private func _calculateByFixedCount(available children: [Measure]) -> CGSize {
        let line = getLine(from: children)

        var fakeLines = [VirtualLinearRegulator]()
        fakeLines.reserveCapacity(line)
        for idx in 0 ..< line {
            let lineChildren = children[idx * arrange ..< min(idx * arrange + arrange, children.count)]
            fakeLines.append(getVirtualLine(children: Array(lineChildren), index: idx))
        }

        let virtualRegulator = getVirtualRegulator(children: fakeLines)
        let size = virtualRegulator.calculate(by: residual)
        fakeLines.forEach { $0.justifyChildrenWithCenter() }
        return size
    }
}

private extension FlowCalculator {
    func getVirtualRegulator(children: [Measure]) -> VirtualLinearRegulator {
        let outside = VirtualLinearRegulator(delegate: VirtualTarget(children: children))
        outside.justifyContent = regulator.justifyContent
        outside.alignment = regulator.alignment
        outside.direction = regDirection
        outside.space = regulator.runSpace
        outside.format = regulator.runFormat
        outside.margin = regulator.margin
        outside.padding = regulator.padding
        outside.reverse = regulator.reverse
        outside.size = regulator.size
        outside.calculatedSize = regulator.calculatedSize
        return outside
    }

    func getVirtualLine(children: [Measure], index: Int) -> VirtualLinearRegulator {
        let line = VirtualLinearRegulator(delegate: VirtualTarget(children: children))
        line.justifyContent = regulator.justifyContent
        line.direction = getOppsiteDirection()
        line.space = regulator.itemSpace
        line.format = regulator.format
        line.reverse = regulator.reverse
        line.alignment = regulator.alignment

        let lineMain = regulator.runRowSize(index)
        var lineCross = SizeDescription.wrap

        if !regCalSize.cross.isWrap {
            lineCross = .fill
        }

        line.size = CalSize(main: lineMain, cross: lineCross, direction: regDirection).getSize()

        return line
    }

    func getLine(from children: [Measure]) -> Int {
        let base = children.count / regulator.arrange
        let more = children.count % regulator.arrange
        return base + (more > 0 ? 1 : 0)
    }

    func getOppsiteDirection() -> Direction {
        return regDirection == .x ? .y : .x
    }
}

private class VirtualLinearRegulator: LinearRegulator {
    private var virtualDelegate: MeasureDelegate?

    override init(delegate: MeasureDelegate?) {
        super.init(delegate: delegate)
        virtualDelegate = delegate
        calculateChildrenImmediately = true
    }

    func justifyChildrenWithCenter() {
        let center = calculatedCenter
        let size = calculatedSize

        // 计算虚拟位置的偏移量
        let delta = CGPoint(x: center.x - size.width / 2, y: center.y - size.height / 2)

        delegate?.enumerateChild { m in
            var center = m.calculatedCenter
            center.x += delta.x
            center.y += delta.y
            m.calculatedCenter = center
        }
    }
}

private class VirtualTarget: MeasureDelegate {
    init(children: [Measure]) {
        self.children = children
    }

    func enumerateChild(_ block: (Measure) -> Void) {
        children.forEach(block)
    }

    func py_sizeThatFits(_ size: CGSize) -> CGSize {
        return size
    }

    var children = [Measure]()

    func py_setNeedsRelayout() {}
}
