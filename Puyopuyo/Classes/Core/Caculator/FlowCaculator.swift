//
//  FlowCaculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/8/20.
//

import Foundation

private class _FakeFlatLayout: FlatLayout, MeasureTargetable {
    
    var py_size: CGSize = .zero
    
    var py_center: CGPoint = .zero {
        didSet {
            children.forEach { (m) in
                if let target = m.target {
                    var center = target.py_center
                    center.x += py_center.x - py_size.width / 2
                    center.y += py_center.y - py_size.height / 2
                    target.py_center = center
                }
            }
        }
    }
    
    func py_enumerateChild(_ block: (Int, Measure) -> Void) {
        children.enumerated().forEach {
            block($0, $1)
        }
    }
    
    func py_sizeThatFits(_ size: CGSize) -> CGSize {
        let temp = PlaceHolderMeasure()
        temp.target?.py_size = size
        let sizeAfterCalulate = caculate(byParent: temp)
        let fixedSize = Caculator.caculate(size: sizeAfterCalulate, by: size)
        return CGSize(width: fixedSize.width.fixedValue, height: fixedSize.height.fixedValue)
    }
    
    var children = [Measure]()
    required init(children: [Measure]) {
        super.init(target: nil)
        target = self
        self.children = children
    }
}

class FlowCaculator {
    let layout: FlowLayout
    let parent: Measure
    var arrange: Int {
        return layout.arrange
    }
    var layoutDirection: Direction {
        return layout.direction
    }
    init(_ layout: FlowLayout, parent: Measure) {
        self.layout = layout
        self.parent = parent
    }
    
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
            let fakeLine = _FakeFlatLayout(children: Array(lineChildren))
            fakeLines.append(fakeLine)
            
            fakeLine.justifyContent = layout.justifyContent
            fakeLine.direction = getOppsiteDirection()
            fakeLine.space = getOppsiteSpace()
            fakeLine.formation = getOppsiteFormation()
            fakeLine.size = Size(width: .wrap, height: .wrap)
            
            let size = fakeLine.caculate(byParent: layout)
            fakeLine.target?.py_size = CGSize(width: size.width.fixedValue, height: size.height.fixedValue)
        }
        
        let outside = _FakeFlatLayout(children: fakeLines)
        outside.justifyContent = layout.justifyContent
        outside.direction = layoutDirection
        outside.space = getNormalSpace()
        outside.formation = getNormalFormation()
        outside.padding = layout.padding
        outside.size = layout.size
        
        return outside.caculate(byParent: parent)
    }
}

private extension FlowCaculator {
    func getLine(from children: [Measure]) -> Int {
        let base = children.count / layout.arrange
        let more = children.count % layout.arrange
        return base + (more > 0 ? 1 : 0)
    }
    
    func getNormalFormation() -> Formation {
        if layoutDirection == .x {
            return layout.hFormation
        }
        return layout.vFormation
    }
    
    func getOppsiteFormation() -> Formation {
        if layoutDirection == .x {
            return layout.vFormation
        }
        return layout.hFormation
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
