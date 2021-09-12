//
//  FlowCalculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/8/20.
//

import Foundation

private class VirtualFlatRegulator: FlatRegulator {
    override init(target: MeasureTargetable? = nil, children: [Measure] = []) {
        super.init(target: target, children: children)
        calculateChildrenImmediately = true
    }

    func justifyChildrenWithCenter() {
        let center = py_center
        let size = py_size

        // 计算虚拟位置的偏移量
        let delta = CGPoint(x: center.x - size.width / 2, y: center.y - size.height / 2)

        virtualTarget.children.forEach { m in
            let target = m.getRealTarget()
            var center = target.py_center
            center.x += delta.x // - oldDelta.x
            center.y += delta.y // - oldDelta.y
            target.py_center = center
        }
    }
}

class FlowCalculator {
    init(_ regulator: FlowRegulator, remain: CGSize) {
        self.regulator = regulator
        self.remain = remain
    }

    let regulator: FlowRegulator
    let remain: CGSize
    var arrange: Int { regulator.arrange }

    var regDirection: Direction { regulator.direction }

    lazy var regChildrenRemainCalSize: CalFixedSize = {
        let size = Calculator.getChildRemainSize(self.regulator.size,
                                                 superRemain: self.remain,
                                                 margin: self.regulator.margin,
                                                 padding: self.regulator.padding,
                                                 ratio: nil)
        return CalFixedSize(cgSize: size, direction: self.regDirection)
    }()

    var regCalPadding: CalEdges { CalEdges(insets: regulator.padding, direction: regDirection) }
    var regCalSize: CalSize { CalSize(size: regulator.size, direction: regDirection) }

    func calculate() -> Size {
        var calculateChildren = [Measure]()
        regulator.py_enumerateChild { m in
            if m.activated {
                calculateChildren.append(m)
            }
        }
        if regulator.arrange > 0 {
            return _calculateByFixedCount(available: calculateChildren)
        }
        return _calculateByContent(available: calculateChildren)
    }

    private func _calculateByContent(available children: [Measure]) -> Size {
        var virtualLines = [VirtualFlatRegulator]()

        var currentLine = [Measure]()
        var maxCross: CGFloat = 0
//        let totalCross = regRemainCalSize.cross - regCalPadding.crossFixed
        let totalCross = regChildrenRemainCalSize.cross

        func getLength(from size: SizeDescription) -> CGFloat {
            assert(!size.isWrap)
            if size.isRatio {
                return .greatestFiniteMagnitude
            }
            return size.fixedValue
        }

        children.enumerated().forEach { _, m in
            let subCalSize = m.calculate(remain: regChildrenRemainCalSize.getSize()).getCalSize(by: regDirection)
            let subCalMargin = CalEdges(insets: m.margin, direction: regDirection)
            let subCrossSize = subCalSize.cross

//            let space = CGFloat(min(1, currentLine.count)) * getOppsiteSpace()
            let space = CGFloat(min(1, currentLine.count)) * regulator.itemSpace
            // 计算当前累计的最大cross
            if subCrossSize.isRatio, maxCross + space + subCalMargin.crossFixed < totalCross {
                // 还有剩余空间
                maxCross = totalCross
            } else {
                maxCross += (getLength(from: subCrossSize) + space + subCalMargin.crossFixed)
            }

            if maxCross > totalCross { // 内容超出
                if currentLine.isEmpty {
                    virtualLines.append(getVirtualLine(children: [m], index: virtualLines.count))
                } else {
                    // 之前的行先归档
                    virtualLines.append(getVirtualLine(children: currentLine, index: virtualLines.count))
                    maxCross = getLength(from: subCrossSize) + subCalMargin.crossFixed
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
        let size = getVirtualRegulator(children: virtualLines).calculate(remain: regChildrenRemainCalSize.getSize())
        virtualLines.forEach { $0.justifyChildrenWithCenter() }
        return size
    }

    private func _calculateByFixedCount(available children: [Measure]) -> Size {
        let line = getLine(from: children)

        var fakeLines = [VirtualFlatRegulator]()
        fakeLines.reserveCapacity(line)
        for idx in 0 ..< line {
            let lineChildren = children[idx * arrange ..< min(idx * arrange + arrange, children.count)]
            fakeLines.append(getVirtualLine(children: Array(lineChildren), index: idx))
        }

        let virtualRegulator = getVirtualRegulator(children: fakeLines)
        let size = virtualRegulator.calculate(remain: regChildrenRemainCalSize.getSize())
        fakeLines.forEach { $0.justifyChildrenWithCenter() }
        return size
    }
}

private extension FlowCalculator {
    func getVirtualRegulator(children: [Measure]) -> VirtualFlatRegulator {
        let outside = VirtualFlatRegulator(target: nil, children: children)
        outside.justifyContent = regulator.justifyContent
        outside.alignment = regulator.alignment
        outside.direction = regDirection
        outside.space = regulator.runSpace
        outside.format = regulator.runFormat
        outside.margin = regulator.margin
        outside.padding = regulator.padding
        outside.reverse = regulator.reverse
        outside.size = regulator.size
        outside.py_size = regulator.py_size
        return outside
    }

    func getVirtualLine(children: [Measure], index: Int) -> VirtualFlatRegulator {
        let line = VirtualFlatRegulator(children: children)
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

//    func getNormalSpace() -> CGFloat {
//        if regDirection == .x {
//            return regulator.hSpace
//        }
//        return regulator.vSpace
//    }
//
//    func getNormalFormat() -> Format {
//        if regDirection == .x {
//            return regulator.hFormat
//        }
//        return regulator.vFormat
//    }
//
//    func getOppsiteFormat() -> Format {
//        if regDirection == .x {
//            return regulator.vFormat
//        }
//        return regulator.hFormat
//    }
//
//    func getOppsiteSpace() -> CGFloat {
//        if regDirection == .x {
//            return regulator.vSpace
//        }
//        return regulator.hSpace
//    }

    func getOppsiteDirection() -> Direction {
        return regDirection == .x ? .y : .x
    }
}
