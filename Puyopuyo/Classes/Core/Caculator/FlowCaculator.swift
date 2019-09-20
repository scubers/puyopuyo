//
//  FlowCaculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/8/20.
//

import Foundation

private class VirtualFlatRegulator: FlatRegulator {
    
    override func caculate(byParent parent: Measure) -> Size {
        // 虚拟布局，计算前，需要应用一下当前自身设置
        Caculator.adapting(size: size, to: self, in: parent)
        return super.caculate(byParent: parent)
    }

    func justifyChildrenWithCenter() {
        let center = py_center
        let size = py_size
        
        // 计算虚拟位置的偏移量
        let lastDelta = CGPoint(x: center.x - size.width / 2, y: center.y - size.height / 2)
        
        virtualTarget.children.forEach { (m) in
            let target = m.getRealTarget()
            var center = target.py_center
            center.x += lastDelta.x// - oldDelta.x
            center.y += lastDelta.y// - oldDelta.y
            target.py_center = center
        }
    }
    
}

class FlowCaculator {
    
    init(_ regulator: FlowRegulator, parent: Measure) {
        self.regulator = regulator
        self.parent = parent
    }
    
    let regulator: FlowRegulator
    let parent: Measure
    var arrange: Int {
        return regulator.arrange
    }
    var layoutDirection: Direction {
        return regulator.direction
    }
    
    lazy var layoutFixedSize = CalFixedSize(cgSize: self.regulator.py_size, direction: regulator.direction)
    lazy var layoutCalPadding = CalEdges(insets: regulator.padding, direction: regulator.direction)
    lazy var layoutCalSize = CalSize(size: regulator.size, direction: regulator.direction)
    
    func caculate() -> Size {
        
        var caculateChildren = [Measure]()
        regulator.enumerateChild { (_, m) in
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
        let totalCross = layoutFixedSize.cross - layoutCalPadding.crossFixed
        
        func getLength(from size: SizeDescription) -> CGFloat {
            assert(!size.isWrap)
            if size.isRatio {
                return .greatestFiniteMagnitude
            }
            return size.fixedValue
        }
        
        children.enumerated().forEach({ (idx, m) in
            let subCalSize = m.caculate(byParent: Measure()).getCalSize(by: regulator.direction)
            let subCalMargin = CalEdges(insets: m.margin, direction: regulator.direction)
            let subCrossSize = subCalSize.cross
            
            let space = CGFloat(min(1, currentLine.count)) * getOppsiteSpace()
            // 计算当前累计的最大cross
            if subCrossSize.isRatio && maxCross + space + subCalMargin.crossFixed < totalCross {
                // 还有剩余空间
                maxCross = totalCross
            } else {
                maxCross += (getLength(from: subCrossSize) + space + subCalMargin.crossFixed)
            }
            
            if maxCross > totalCross { // 内容超出
                if currentLine.isEmpty {
                    virtualLines.append(getVirtualLine(children: [m]))
                } else {
                    // 另起新的一行
                    virtualLines.append(getVirtualLine(children: currentLine))
                    maxCross = getLength(from: subCrossSize) + subCalMargin.crossFixed
                    currentLine = [m]
                }
            } else { // 内容未超出
                currentLine.append(m)
            }
        })
        if !currentLine.isEmpty {
            virtualLines.append(getVirtualLine(children: currentLine))
        }
        let size = getVirtualRegulator(children: virtualLines).caculate(byParent: parent)
        virtualLines.forEach({ $0.justifyChildrenWithCenter() })
        return size
    }
    
    private func _caculateByFixedCount(available children: [Measure]) -> Size {
        let line = getLine(from: children)
        
        var fakeLines = [VirtualFlatRegulator]()
        fakeLines.reserveCapacity(line)
        for idx in 0..<line {
            let lineChildren = children[idx * arrange..<min(idx * arrange + arrange, children.count)]
            fakeLines.append(getVirtualLine(children: Array(lineChildren)))
        }
        
        let virtualRegulator = getVirtualRegulator(children: fakeLines)
        let size = virtualRegulator.caculate(byParent: parent)
        let measure = Measure()
        fakeLines.forEach {
            measure.py_size = $0.py_size
            _ = $0.caculate(byParent: measure)
            $0.justifyChildrenWithCenter()
        }
        return size
    }
}

private extension FlowCaculator {
    
    func getVirtualRegulator(children: [Measure]) -> VirtualFlatRegulator {
        let outside = VirtualFlatRegulator(target: nil, children: children)
        outside.justifyContent = regulator.justifyContent
        outside.aligment = regulator.aligment
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
        line.aligment = regulator.aligment

        var lineCalSize = CalSize(main: .wrap, cross: .wrap, direction: layoutDirection)
        if !layoutCalSize.cross.isWrap {
            // 当流式布局为包裹的时候，内部计算布局需要给定一个尺寸
            lineCalSize.cross = .fix(max(0, layoutFixedSize.cross - regulator.getCalPadding().crossFixed))
        }
        for m in children {
            if m.size.getCalSize(by: layoutDirection).main.isRatio {
                lineCalSize.main = .ratio(1)
                break
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
