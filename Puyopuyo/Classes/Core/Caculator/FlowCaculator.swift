//
//  FlowCaculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/8/20.
//

import Foundation

private class VirtualFlatRegulator: FlatRegulator {
    override init(target: MeasureTargetable? = nil, children: [Measure] = []) {
        super.init(target: target, children: children)
        caculateChildrenImmediately = true
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

class FlowCaculator {
    init(_ regulator: FlowRegulator, parent: Measure, remain: CGSize) {
        self.regulator = regulator
        self.parent = parent
        self.remain = remain
    }

    let regulator: FlowRegulator
    let parent: Measure
    let remain: CGSize
    var arrange: Int { regulator.arrange }

    var layoutDirection: Direction { regulator.direction }

    lazy var regRemainCalSize: CalFixedSize = {
        let size = Caculator.getChildRemainSize(self.regulator.size,
                                                superRemain: self.remain,
                                                margin: self.regulator.margin,
                                                padding: self.regulator.padding,
                                                ratio: nil)
        return CalFixedSize(cgSize: size, direction: self.regulator.direction)
    }()

    var regCalPadding: CalEdges { CalEdges(insets: regulator.padding, direction: regulator.direction) }
    var regCalSize: CalSize { CalSize(size: regulator.size, direction: regulator.direction) }

    func caculate() -> Size {
        var caculateChildren = [Measure]()
        regulator.enumerateChild { _, m in
            if m.activated {
                caculateChildren.append(m)
            }
        }
        if regulator.arrange > 0 {
            return _caculateByFixedCount(available: caculateChildren)
        }
        return _caculateByContent(available: caculateChildren)
    }

    private func _caculateByContent(available children: [Measure]) -> Size {
        var virtualLines = [VirtualFlatRegulator]()

        var currentLine = [Measure]()
        var maxCross: CGFloat = 0
//        let totalCross = regRemainCalSize.cross - regCalPadding.crossFixed
        let totalCross = regRemainCalSize.cross

        func getLength(from size: SizeDescription) -> CGFloat {
            assert(!size.isWrap)
            if size.isRatio {
                return .greatestFiniteMagnitude
            }
            return size.fixedValue
        }

        children.enumerated().forEach { _, m in
            let subCalSize = m.caculate(byParent: Measure(), remain: remain).getCalSize(by: regulator.direction)
            let subCalMargin = CalEdges(insets: m.margin, direction: regulator.direction)
            let subCrossSize = subCalSize.cross

            let space = CGFloat(min(1, currentLine.count)) * getOppsiteSpace()
            // 计算当前累计的最大cross
            if subCrossSize.isRatio, maxCross + space + subCalMargin.crossFixed < totalCross {
                // 还有剩余空间
                maxCross = totalCross
            } else {
                maxCross += (getLength(from: subCrossSize) + space + subCalMargin.crossFixed)
            }

            if maxCross > totalCross { // 内容超出
                if currentLine.isEmpty {
                    virtualLines.append(getVirtualLine(children: [m]))
                } else {
                    // 之前的行先归档
                    virtualLines.append(getVirtualLine(children: currentLine))
                    maxCross = getLength(from: subCrossSize) + subCalMargin.crossFixed
                    // 另起新的一行
                    currentLine = [m]
                }
            } else { // 内容未超出
                currentLine.append(m)
            }
            // 主动换行
            if m.flowEnding {
                virtualLines.append(getVirtualLine(children: currentLine))
                currentLine = []
                maxCross = 0
            }
        }
        if !currentLine.isEmpty {
            virtualLines.append(getVirtualLine(children: currentLine))
        }
        let size = getVirtualRegulator(children: virtualLines).caculate(byParent: parent, remain: remain)
        virtualLines.forEach { $0.justifyChildrenWithCenter() }
        return size
    }

    private func _caculateByFixedCount(available children: [Measure]) -> Size {
        let line = getLine(from: children)

        var fakeLines = [VirtualFlatRegulator]()
        fakeLines.reserveCapacity(line)
        for idx in 0 ..< line {
            let lineChildren = children[idx * arrange ..< min(idx * arrange + arrange, children.count)]
            fakeLines.append(getVirtualLine(children: Array(lineChildren)))
        }

        let virtualRegulator = getVirtualRegulator(children: fakeLines)
        let size = virtualRegulator.caculate(byParent: parent, remain: remain)
        fakeLines.forEach { $0.justifyChildrenWithCenter() }
        return size
    }
}

private extension FlowCaculator {
    func getVirtualRegulator(children: [Measure]) -> VirtualFlatRegulator {
        let outside = VirtualFlatRegulator(target: nil, children: children)
        outside.justifyContent = regulator.justifyContent
        outside.alignment = regulator.alignment
        outside.direction = layoutDirection
        outside.space = getNormalSpace()
        outside.format = getNormalFormat()
        outside.margin = regulator.margin
        outside.padding = regulator.padding
        outside.reverse = regulator.reverse
        outside.size = regulator.size
        outside.py_size = regulator.py_size
        return outside
    }

    func getVirtualLine(children: [Measure]) -> VirtualFlatRegulator {
        let line = VirtualFlatRegulator(children: children)
        line.justifyContent = regulator.justifyContent
        line.direction = getOppsiteDirection()
        line.space = getOppsiteSpace()
        line.format = getOppsiteFormat()
        line.reverse = regulator.reverse
        line.alignment = regulator.alignment

        var lineCalSize = CalSize(main: .wrap, cross: .wrap, direction: layoutDirection)
        if !regCalSize.cross.isWrap {
            // 当流式布局为非包裹的时候，内部计算布局优先撑满
            lineCalSize.cross = .fill
        }

        if regCalSize.main.isWrap, regulator.stretchRows {
            print("FlowRegulator: \(regulator), cannot stretch rows when main is wrap, reset to false")
            regulator.stretchRows = false
        }

        if regulator.stretchRows {
            lineCalSize.main = .fill
        }

        if !regCalSize.main.isWrap {
            // 找出最大的main
            var maxRatio: CGFloat?
            var maxPriority: Double?
            children.forEach { m in
                let size = m.size.getCalSize(by: layoutDirection)
                if size.main.isRatio {
                    if let m = maxRatio {
                        maxRatio = max(m, size.main.ratio)
                    } else {
                        maxRatio = size.main.ratio
                    }
                }
                if size.main.isWrap {
                    if let m = maxPriority {
                        maxPriority = max(m, size.main.priority)
                    } else {
                        maxPriority = size.main.priority
                    }
                }
            }
            if let max = maxRatio {
                lineCalSize.main = .ratio(max)
            }
            if let max = maxPriority {
                lineCalSize.main = .wrap(priority: max)
            }
        }

        line.size = lineCalSize.getSize()
        return line
    }

    func getLine(from children: [Measure]) -> Int {
        let base = children.count / regulator.arrange
        let more = children.count % regulator.arrange
        return base + (more > 0 ? 1 : 0)
    }

    func getNormalSpace() -> CGFloat {
        if layoutDirection == .x {
            return regulator.hSpace
        }
        return regulator.vSpace
    }

    func getNormalFormat() -> Format {
        if layoutDirection == .x {
            return regulator.hFormat
        }
        return regulator.vFormat
    }

    func getOppsiteFormat() -> Format {
        if layoutDirection == .x {
            return regulator.vFormat
        }
        return regulator.hFormat
    }

    func getOppsiteSpace() -> CGFloat {
        if layoutDirection == .x {
            return regulator.vSpace
        }
        return regulator.hSpace
    }

    func getOppsiteDirection() -> Direction {
        return layoutDirection == .x ? .y : .x
    }
}
