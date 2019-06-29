//
//  Size.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import UIKit

public enum Direction {
    case x, y
}

public struct Aligment: OptionSet {
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    public typealias RawValue = Int
    public let rawValue: Int
    
    public static let top = Aligment(rawValue: 1)
    public static let bottom = Aligment(rawValue: 2)
    public static let left = Aligment(rawValue: 4)
    public static let right = Aligment(rawValue: 8)
    public static let center = Aligment(rawValue: 16)
    
    public static let none = Aligment(rawValue: 32)
    
    public func isCenter() -> Bool {
        return contains(.center)
    }
    
    public func isForward(for direction: Direction) -> Bool {
        if case .x = direction {
            return contains(.bottom)
        }
        return contains(.left)
    }
    
    public func isBackward(for direction: Direction) -> Bool {
        if case .x = direction {
            return contains(.top)
        }
        return contains(.right)
    }
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

    public var margin = UIEdgeInsets.zero
    
    public var aligment: Aligment = .none
    
    public var size = Size()
    
    public var activated = true
    
    public func caculate(byParent parent: Measure) -> Size {
        return MeasureCaculator.caculate(measure: self, byParent: parent)
    }
    
}

public class PlaceHolderMeasure: Measure, MeasureTagetable {
    
    public init() {
        super.init()
        target = self
    }
    
    public var py_size: CGSize = .zero
    
    public var py_center: CGPoint = .zero
    
    public func py_enumerateChild(_ block: (Int, Measure) -> Void) {
        
    }
    
    public func py_sizeThatFits(_ size: CGSize) -> CGSize {
        return size
    }
}
