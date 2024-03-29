//
//  FlowCalculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/8/20.
//

import Foundation

struct FlowCalculator: Calculator {
    func calculate(_ measure: Measure, layoutResidual: CGSize) -> CGSize {
        _FlowCalculator(measure as! FlowRegulator, layoutResidual: layoutResidual).calculate()
    }
}

class _FlowCalculator {
    init(_ regulator: FlowRegulator, layoutResidual: CGSize) {
        self.regulator = regulator
        self.layoutResidual = layoutResidual
    }

    let regulator: FlowRegulator
    let layoutResidual: CGSize
    var arrange: Int { regulator.arrange }

    var regDirection: Direction { regulator.direction }

    lazy var regChildrenResidualCalSize: CalFixedSize = {
        let size = ResidualHelper.getChildrenLayoutResidual(for: regulator, regulatorLayoutResidual: layoutResidual)
        return CalFixedSize(cgSize: size, direction: regDirection)
    }()

//    var regCalPadding: CalEdges { CalEdges(insets: regulator.padding, direction: regDirection) }
    var regSemanticDirection: SemanticDirection { regulator.semanticDirection ?? PuyoAppearence.semanticDirection }
    var regCalSize: CalSize { CalSize(size: regulator.size, direction: regDirection) }

    func calculate() -> CGSize {
        var calculateChildren = [Measure]()
        calculateChildren.reserveCapacity(regulator.children.count)
        regulator.enumerateChildren { m in
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

            let subCalFixedSize = IntrinsicSizeHelper.calculateIntrinsicSize(for: m, layoutResidual: regChildrenResidualCalSize.getSize(), strategy: m.isLayoutEntryPoint ? .estimate : .calculate, diagnosisMsg: "FlowCalculator content test calculating").getCalFixedSize(by: regDirection)
            let subCalMargin = CalEdges(insets: m.margin, direction: regDirection, in: regSemanticDirection)

            let space = CGFloat(Swift.min(1, currentLine.count)) * regulator.itemSpace
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
        let size = getVirtualRegulator(children: virtualLines).calculate(by: layoutResidual)
        virtualLines.forEach { $0.justifyChildrenWithCenter() }
        return size
    }

    private func _calculateByFixedCount(available children: [Measure]) -> CGSize {
        let line = getLine(from: children)

        var fakeLines = [VirtualLinearRegulator]()
        fakeLines.reserveCapacity(line)
        for idx in 0 ..< line {
            let lineChildren = children[idx * arrange ..< Swift.min(idx * arrange + arrange, children.count)]
            fakeLines.append(getVirtualLine(children: Array(lineChildren), index: idx))
        }

        let virtualRegulator = getVirtualRegulator(children: fakeLines)
        let size = virtualRegulator.calculate(by: layoutResidual)
        fakeLines.forEach { $0.justifyChildrenWithCenter() }
        return size
    }
}

private extension _FlowCalculator {
    func getVirtualRegulator(children: [Measure]) -> VirtualLinearRegulator {
        let outside = VirtualLinearRegulator(children: children)
        outside.justifyContent = regulator.justifyContent
        outside.alignment = regulator.alignment
        outside.direction = regDirection
        outside.space = regulator.runSpace
        outside.format = regulator.runFormat
        outside.margin = regulator.margin
        outside.padding = regulator.padding
        outside.reverse = regulator.reverse
        outside.size = regulator.size
        return outside
    }

    func getVirtualLine(children: [Measure], index: Int) -> VirtualLinearRegulator {
        let line = VirtualLinearRegulator(children: children)
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

private class VirtualLinearRegulator: LinearRegulator, MeasureChildrenDelegate {
    /// make sure delegate alive
    private let virtualChildren: [Measure]

    init(children: [Measure]) {
        self.virtualChildren = children
        super.init(delegate: nil, sizeDelegate: nil, childrenDelegate: nil)
        childrenDelegate = self
    }

    func justifyChildrenWithCenter() {
        let center = calculatedCenter
        let size = calculatedSize

        // 计算虚拟位置的偏移量
        let delta = CGPoint(x: center.x - size.width / 2, y: center.y - size.height / 2)

        enumerateChildren { m in
            m.calculatedCenter.x += delta.x
            m.calculatedCenter.y += delta.y
        }
    }

    override func createCalculator() -> Calculator {
        LinearCalculator()
    }

    func children(for measure: Measure) -> [Measure] {
        virtualChildren
    }

    func measureIsLayoutEntry(_ measure: Measure) -> Bool {
        false
    }
}
