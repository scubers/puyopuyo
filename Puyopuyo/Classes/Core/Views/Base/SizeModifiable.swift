//
//  SizeModifiable.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/8/26.
//

import Foundation

public protocol ValueModifiable {
    func modifyValue() -> State<CGFloat>
}

public struct Simulate {
    
    var view: UIView
    
    var transform: (CGRect) -> CGFloat = { _ in 0}
    var add: CGFloat = 0
    var multiply: CGFloat = 1
    
    var selfSimulating = false
    
    public init(_ view: UIView) {
        self.view = view
    }
    
    private init() {
        self.view = UIView()
        selfSimulating = true
    }
    
    public static var ego: Simulate {
        return Simulate()
    }
    
    public func add(_ add: CGFloat) -> Simulate {
        var s = self
        s.add = add
        return s
    }
    
    public func multiply(_ multiply: CGFloat) -> Simulate {
        var s = self
        s.multiply = multiply
        return s
    }
    
    public func simulate(_ view: UIView) -> Simulate {
        var s = self
        s.view = view
        return s
    }
    
    public func simulateSelf() -> Simulate {
        var s = self
        s.selfSimulating = true
        return s
    }
}

extension Simulate: ValueModifiable {
    
    public var height: Simulate {
        var s = self
        s.transform = { $0.height }
        return s
    }
    
    public var width: Simulate {
        var s = self
        s.transform = { $0.width }
        return s
    }
    
    public var top: Simulate {
        var s = self
        s.transform = { $0.origin.y }
        return s
    }
    
    public var left: Simulate {
        var s = self
        s.transform = { $0.origin.x }
        return s
    }
    
    public var bottom: Simulate {
        var s = self
        s.transform = { $0.maxY }
        return s
    }
    
    public var right: Simulate {
        var s = self
        s.transform = { $0.maxX }
        return s
    }
    
    public func modifyValue() -> State<CGFloat> {
        let transform = self.transform
        let multiply = self.multiply
        let add = self.add
        return
            view
                .py_frameStateByBoundsCenter()
                .map({ transform($0) * multiply + add })
                .distinct()
    }
}

extension ValueModifiable {
    public func checkSelfSimulate(_ view: UIView) -> ValueModifiable {
        if let m = self as? Simulate, m.selfSimulating {
            return m.simulate(view)
        }
        return self
    }
}

extension State: ValueModifiable where Value == CGFloat {
    public func modifyValue() -> State<CGFloat> {
        return self
    }
}
