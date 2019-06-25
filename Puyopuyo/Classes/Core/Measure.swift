//
//  Size.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import UIKit

public enum Aligment {
    case none
    case forward
    case center
    case backward
}


public enum Direction {
    case x, y
}

/// 描述一个节点相对于父节点的属性
public class Measure: Measurable {
    
    weak var target: MeasureTagetable?
    
    public init(target: MeasureTagetable? = nil) {
        self.target = target
    }
    
    public var direction: Direction = .x {
        willSet {
            // 普通节点不能更改方向属性
            assert(type(of: self) != Measure.self)
        }
    }

    public var margin = Edges()
    
    public var aligment: Aligment = .none
    
    public var size = Size()
    
    public var ignore = false
    
    public func caculate(from parent: Measure) -> Size {
        return MeasureCaculator.caculate(measure: self, from: parent)
    }
    
}

public class PlaceHolderMeasure: Measure, MeasureTagetable {
    
    public init() {
        super.init()
        target = self
    }
    
    public var py_size: CGSize = .zero
    
    public var py_center: CGPoint = .zero
    
    public var py_children: [Measure] = []
    
    public var py_wrapSize: CGSize = .zero
    
    public func py_sizeThatFits(_ size: CGSize) -> CGSize {
        return size
    }
}

/// 描述一个布局具备控制子节点的属性
public class BaseLayout: Measure {
    
    public var padding = Edges()
    
    public var children: [Measure] {
        return target?.py_children ?? []
    }
}

public enum Formation {
    case line
    case center
    case sides
}

public class LineLayout: BaseLayout {
    
    public var crossAxis: Aligment = .none
    
    public var space: CGFloat = 0
    
    public var formation: Formation = .line
    
    public var reverse = false
    
    public override func caculate(from parent: Measure) -> Size {
        return LineCaculator.caculateLine(self, from: parent)
    }
}

public class ZLayout: BaseLayout {
    
}
