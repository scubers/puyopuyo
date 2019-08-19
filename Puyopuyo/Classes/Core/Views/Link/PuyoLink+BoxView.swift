//
//  PuyoLink+ListBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/2.
//

import Foundation

// MARK: - BoxView
extension PuyoLink where T: BoxView {
    @discardableResult
    public func padding(all: CGFloat? = nil, top: CGFloat? = nil, left: CGFloat? = nil, bottom: CGFloat? = nil, right: CGFloat? = nil) -> Self {
        if let all = all {
            view.layout.padding = UIEdgeInsets(top: all, left: all, bottom: all, right: all)
        }
        if let top = top { view.layout.padding.top = top }
        if let left = left { view.layout.padding.left = left }
        if let bottom = bottom { view.layout.padding.bottom = bottom }
        if let right = right { view.layout.padding.right = right }
        setNeedsLayout()
        return self
    }
    
    @discardableResult
    public func padding<S: Valuable>(_ padding: S) -> Self where S.ValueType == UIEdgeInsets {
        view.py_setUnbinder(padding.safeBind(view, { (v, i) in
            v.layout.padding = i
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func justifyContent(_ aligment: Aligment) -> Self {
        view.layout.justifyContent = aligment
        setNeedsLayout()
        return self
    }
    
    @discardableResult
    public func justifyContent<S: Valuable>(_ aligment: S) -> Self where S.ValueType == Aligment {
        view.py_setUnbinder(aligment.safeBind(view, { (v, a) in
            v.layout.justifyContent = a
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
}

// MARK: - FlatBox
extension PuyoLink where T: FlatBox {
    
    @discardableResult
    public func space(_ space: CGFloat) -> Self {
        view.layout.space = space
        setNeedsLayout()
        return self
    }
    
    @discardableResult
    public func space<S: Valuable>(_ space: S) -> Self where S.ValueType == CGFloat {
        view.py_setUnbinder(space.safeBind(view, { (v, s) in
            v.layout.space = s
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func formation(_ formation: Formation) -> Self {
        view.layout.formation = formation
        setNeedsLayout()
        return self
    }
    
    @discardableResult
    public func formation<S: Valuable>(_ formation: S) -> Self where S.ValueType == Formation {
        view.py_setUnbinder(formation.safeBind(view, { (v, f) in
            v.layout.formation = f
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func direction(_ direction: Direction) -> Self {
        view.layout.direction = direction
        setNeedsLayout()
        return self
    }
    
    @discardableResult
    public func direction<S: Valuable>(_ direction: S) -> Self where S.ValueType == Direction {
        view.py_setUnbinder(direction.safeBind(view, { (v, d) in
            v.layout.direction = d
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func reverse(_ reverse: Bool) -> Self {
        view.layout.reverse = reverse
        setNeedsLayout()
        return self
    }
    
    @discardableResult
    public func reverse<S: Valuable>(_ reverse: S) -> Self where S.ValueType == Bool {
        view.py_setUnbinder(reverse.safeBind(view, { (v, r) in
            v.layout.reverse = r
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func autoJudgeScroll(_ judge: Bool) -> Self {
        view.layout.autoJudgeScroll = judge
        setNeedsLayout()
        return self
    }
}
