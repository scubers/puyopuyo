//
//  FlowCaculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/8/20.
//

import Foundation

private class _FakeFlatLayout: FlatRegulator {
    
    private var lastDelta: CGPoint = .zero
    
    override var py_center: CGPoint {
        didSet {
            let outCenter = py_center
            let size = py_size

            // 计算虚拟位置的偏移量
            let oldDelta = lastDelta
            lastDelta = CGPoint(x: outCenter.x - size.width / 2, y: outCenter.y - size.height / 2)
            
            fakeTarget.children.forEach { (m) in
                let target = m.getRealTarget()
                var center = target.py_center
                center.x += lastDelta.x - oldDelta.x
                center.y += lastDelta.y - oldDelta.y
                target.py_center = center
            }
        }
    }
    
    override func caculate(byParent parent: Measure) -> Size {
        // 每次自身布局，都需要清空虚拟位置的偏移量
        lastDelta = .zero
        // 虚拟布局，计算前，需要应用一下当前自身设置
        Caculator.adapting(size: size, to: self, in: parent)
        return super.caculate(byParent: parent)
    }
    
}

class FlowCaculator {
    
    init(_ layout: FlowRegulator, parent: Measure) {
        self.layout = layout
        self.parent = parent
    }
    
    let layout: FlowRegulator
    let parent: Measure
    var arrange: Int {
        return layout.arrange
    }
    var layoutDirection: Direction {
        return layout.direction
    }
    
    lazy var layoutFixedSize = CalFixedSize(cgSize: self.layout.py_size, direction: layout.direction)
    lazy var layoutCalPadding = CalEdges(insets: layout.padding, direction: layout.direction)
    lazy var layoutCalSize = CalSize(size: layout.size, direction: layout.direction)
    
    func caculate() -> Size {
        
        var caculateChildren = [Measure]()
        layout.enumerateChild { (_, m) in
            if m.activated {
                caculateChildren.append(m)
            }
        }
        if layout.arrange > 0 {
            return _caculateByFixedCount(available: caculateChildren)
        }
        return _caculateByContent(available: caculateChildren)
    }
    
    private func _caculateByContent(available children: [Measure]) -> Size {
        
        var fakeLines = [_FakeFlatLayout]()
        
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
            let subCalSize = m.caculate(byParent: Measure()).getCalSize(by: layout.direction)
            let subCalMargin = CalEdges(insets: m.margin, direction: layout.direction)
            let subCrossSize = subCalSize.cross
            // 计算当前累计的最大cross
            let subCross = (getLength(from: subCrossSize) + max(0, CGFloat(currentLine.count) * getOppsiteSpace())) + subCalMargin.crossFixed
            
            if (maxCross + subCross) > totalCross { // 内容超出
                if currentLine.isEmpty {
                    fakeLines.append(constructFakeLine(children: [m]))
                } else {
                    fakeLines.append(constructFakeLine(children: currentLine))
                    maxCross = getLength(from: subCrossSize) + subCalMargin.crossFixed
                    currentLine = [m]
                }
            } else { // 内容未超出
                currentLine.append(m)
                maxCross += subCross
            }
        })
        if !currentLine.isEmpty {
            fakeLines.append(constructFakeLine(children: currentLine))
        }
        let size = constructFakeOutside(children: fakeLines).caculate(byParent: parent)
        return size
    }
    
    private func _caculateByFixedCount(available children: [Measure]) -> Size {
        let line = getLine(from: children)
        
        var fakeLines = [_FakeFlatLayout]()
        fakeLines.reserveCapacity(line)
        for idx in 0..<line {
            let lineChildren = children[idx * arrange..<min(idx * arrange + arrange, children.count)]
            fakeLines.append(constructFakeLine(children: Array(lineChildren)))
        }
        
        let size = constructFakeOutside(children: fakeLines).caculate(byParent: parent)
        return size
    }
}

private extension FlowCaculator {
    
    func constructFakeOutside(children: [Measure]) -> _FakeFlatLayout {
        let outside = _FakeFlatLayout(target: nil, children: children)
        outside.justifyContent = layout.justifyContent
        outside.aligment = layout.aligment
        outside.direction = layoutDirection
        outside.space = getNormalSpace()
        outside.format = getNormalFormat()
        outside.margin = layout.margin
        outside.padding = layout.padding
        outside.reverse = layout.reverse
        outside.size = layout.size
        outside.py_size = layout.py_size
        return outside
    }
    
    func constructFakeLine(children: [Measure]) -> _FakeFlatLayout {
        let line = _FakeFlatLayout(children: children)
        line.justifyContent = layout.justifyContent
        line.direction = getOppsiteDirection()
        line.space = getOppsiteSpace()
        line.format = getOppsiteFormat()
        line.reverse = layout.reverse
        line.aligment = layout.aligment

        var lineCalSize = CalSize(main: .wrap, cross: .wrap, direction: layoutDirection)
        if !layoutCalSize.cross.isWrap {
            // 当流式布局为包裹的时候，内部计算布局需要给定一个尺寸
            lineCalSize.cross = .fix(max(0, layoutFixedSize.cross - layout.getCalPadding().crossFixed))
        }
        line.size = lineCalSize.getSize()
        let size = line.caculate(byParent: layout)
        line.py_size = CGSize(width: size.width.fixedValue, height: size.height.fixedValue)
        return line
    }
    
    func getLine(from children: [Measure]) -> Int {
        let base = children.count / layout.arrange
        let more = children.count % layout.arrange
        return base + (more > 0 ? 1 : 0)
    }
    
    func getNormalSpace() -> CGFloat {
        if layoutDirection == .x {
            return layout.hSpace
        }
        return layout.vSpace
    }
    
    func getNormalFormat() -> Format {
        if layoutDirection == .x {
            return layout.hFormat
        }
        return layout.vFormat
    }
    
    func getOppsiteFormat() -> Format {
        if layoutDirection == .x {
            return layout.vFormat
        }
        return layout.hFormat
    }
    
    func getOppsiteSpace() -> CGFloat {
        if layoutDirection == .x {
            return layout.vSpace
        }
        return layout.hSpace
    }
    
    func getOppsiteDirection() -> Direction {
        return layoutDirection == .x ? .y : .x
    }
}
