//
//  SizeModifiable.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/8/26.
//

import Foundation

public protocol SizeModifiable {
    func modifySize() -> State<SizeDescription>
}

public struct Simulate: SizeModifiable {
    
    var view: UIView
    
    var transform: (CGRect) -> CGFloat = { _ in 0}
    var add: CGFloat = 0
    var multiply: CGFloat = 1
    
    public init(_ view: UIView) {
        self.view = view
    }
    
    public func modifySize() -> State<SizeDescription> {
        return view.py_observeBounds({ (rect) -> SizeDescription in
            return .fix(self.transform(rect) * self.multiply + self.add)
        })
    }
    
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
    
}
