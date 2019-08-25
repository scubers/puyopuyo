//
//  FlowCaculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/8/20.
//

import Foundation

private class _FakeFlatLayout: FlatLayout, MeasureTargetable {
    
    private var isPrint = false
    
    var py_size: CGSize = .zero
    
    var py_center: CGPoint = .zero {
        didSet {
            #if DEBUG
            if isPrint {
                print("----------------------")
                print("size: \(py_size)")
                print("center: \(py_center)")
            }
            #endif
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
    required init(children: [Measure], print: Bool = false) {
        super.init(target: nil)
        target = self
        self.children = children
        self.isPrint = print
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
    
    lazy var layoutFixedSize = CalFixedSize(cgSize: self.layout.target?.py_size ?? .zero, direction: layout.direction)
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
        
        return constructFakeOutside(children: fakeLines).caculate(byParent: parent)
    }
}

private extension FlowCaculator {
    
    func constructFakeOutside(children: [Measure]) -> _FakeFlatLayout {
        let outside = _FakeFlatLayout(children: children, print: true)
        outside.justifyContent = layout.justifyContent
        outside.direction = layoutDirection
        outside.space = getNormalSpace()
        outside.formation = getNormalFormation()
        outside.padding = layout.padding
        outside.reverse = layout.reverse
        outside.size = layout.size
        
        let parentCGSize = parent.target?.py_size ?? .zero
        let size = layout.size
        // 本身固有尺寸
        if size.isFixed() || size.isRatio() {
            let size = Caculator.caculate(size: size, by: parentCGSize)
            outside.target?.py_size = CGSize(width: size.width.fixedValue, height: size.height.fixedValue)
        } else {
            if !size.width.isWrap {
                let width = Caculator.caculateFix(size.width, by: parentCGSize.width)
                outside.target?.py_size.width = width.fixedValue
            }
            if !size.height.isWrap {
                let height = Caculator.caculateFix(size.height, by: parentCGSize.height)
                outside.target?.py_size.height = height.fixedValue
            }
        }
        return outside

    }
    
    func constructFakeLine(children: [Measure]) -> _FakeFlatLayout {
        let line = _FakeFlatLayout(children: children)
        line.justifyContent = layout.justifyContent
        line.direction = getOppsiteDirection()
        line.space = getOppsiteSpace()
        line.formation = getOppsiteFormation()
        line.reverse = layout.reverse
        line.size = Size(width: .wrap, height: .wrap)
        
        if line.formation != .leading {
            // 需要外界给定cross
            var calSize = line.size.getCalSize(by: layoutDirection)
            calSize.cross = .fix(layoutFixedSize.cross - layout.getCalPadding().crossFixed)
            line.size = calSize.getSize()
        }
        let size = line.caculate(byParent: layout)
        line.target?.py_size = CGSize(width: size.width.fixedValue, height: size.height.fixedValue)
        return line
    }
    
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
