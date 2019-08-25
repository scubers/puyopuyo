//
//  FlowCaculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/8/20.
//

import Foundation

private class _FakeFlatLayout: FlatLayout {
    
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
        return super.caculate(byParent: parent)
    }
    
}

class FlowCaculator {
    
    init(_ layout: FlowLayout, parent: Measure) {
        self.layout = layout
        self.parent = parent
    }
    
    let layout: FlowLayout
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
        let line = getLine(from: caculateChildren)
        
        var fakeLines = [_FakeFlatLayout]()
        for idx in 0..<line {
            let lineChildren = caculateChildren[idx * arrange..<min(idx * arrange + arrange, caculateChildren.count)]
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
        outside.direction = layoutDirection
        outside.space = getNormalSpace()
        outside.formation = layout.formation
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
        line.formation = layout.subFormation
        line.reverse = layout.reverse
        line.size = Size(width: .wrap, height: .wrap)
        
        if line.formation != .leading {
            // 需要外界给定cross
            var calSize = line.size.getCalSize(by: layoutDirection)
            calSize.cross = .fix(layoutFixedSize.cross - layout.getCalPadding().crossFixed)
            line.size = calSize.getSize()
        }
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
