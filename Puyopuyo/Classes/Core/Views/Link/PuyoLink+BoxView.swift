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
            view.regulator.padding = UIEdgeInsets(top: all, left: all, bottom: all, right: all)
        }
        if let top = top { view.regulator.padding.top = top }
        if let left = left { view.regulator.padding.left = left }
        if let bottom = bottom { view.regulator.padding.bottom = bottom }
        if let right = right { view.regulator.padding.right = right }
        setNeedsLayout()
        return self
    }
    
    @discardableResult
    public func padding<S: ValueOutputing>(_ padding: S) -> Self where S.OutputType == UIEdgeInsets {
        view.py_setUnbinder(padding.safeBind(view, { (v, i) in
            v.regulator.padding = i
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func justifyContent(_ aligment: Aligment) -> Self {
        view.regulator.justifyContent = aligment
        setNeedsLayout()
        return self
    }
    
    @discardableResult
    public func justifyContent<S: ValueOutputing>(_ aligment: S) -> Self where S.OutputType == Aligment {
        view.py_setUnbinder(aligment.safeBind(view, { (v, a) in
            v.regulator.justifyContent = a
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func autoJudgeScroll(_ judge: Bool) -> Self {
        view.regulator.autoJudgeScroll = judge
        setNeedsLayout()
        return self
    }

    
}

// MARK: - FlatBox
extension PuyoLink where T: FlatBox {
    
    @discardableResult
    public func space(_ space: CGFloat) -> Self {
        view.regulator.space = space
        setNeedsLayout()
        return self
    }
    
    @discardableResult
    public func space<S: ValueOutputing>(_ space: S) -> Self where S.OutputType == CGFloat {
        view.py_setUnbinder(space.safeBind(view, { (v, s) in
            v.regulator.space = s
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func format(_ formation: Format) -> Self {
        view.regulator.format = formation
        setNeedsLayout()
        return self
    }
    
    @discardableResult
    public func format<S: ValueOutputing>(_ formation: S) -> Self where S.OutputType == Format {
        view.py_setUnbinder(formation.safeBind(view, { (v, f) in
            v.regulator.format = f
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func direction(_ direction: Direction) -> Self {
        view.regulator.direction = direction
        setNeedsLayout()
        return self
    }
    
    @discardableResult
    public func direction<S: ValueOutputing>(_ direction: S) -> Self where S.OutputType == Direction {
        view.py_setUnbinder(direction.safeBind(view, { (v, d) in
            v.regulator.direction = d
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func reverse(_ reverse: Bool) -> Self {
        view.regulator.reverse = reverse
        setNeedsLayout()
        return self
    }
    
    @discardableResult
    public func reverse<S: ValueOutputing>(_ reverse: S) -> Self where S.OutputType == Bool {
        view.py_setUnbinder(reverse.safeBind(view, { (v, r) in
            v.regulator.reverse = r
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
}

// MARK: - FlowBox
extension PuyoLink where T: FlowBox {
    
    @discardableResult
    public func arrangeCount(_ count: Int) -> Self {
        view.regulator.arrange = count
        setNeedsLayout()
        return self
    }
    
    @discardableResult
    public func arrangeCount<S: ValueOutputing>(_ count: S) -> Self where S.OutputType == Int {
        view.py_setUnbinder(count.safeBind(view, { (v, c) in
            v.regulator.arrange = c
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func hSpace<S: ValueOutputing>(_ space: S) -> Self where S.OutputType == CGFloat {
        view.py_setUnbinder(space.safeBind(view, { (v, s) in
            v.regulator.hSpace = s
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func vSpace<S: ValueOutputing>(_ space: S) -> Self where S.OutputType == CGFloat {
        view.py_setUnbinder(space.safeBind(view, { (v, s) in
            v.regulator.vSpace = s
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func subFormat(_ formation: Format) -> Self {
        view.regulator.subFormat = formation
        setNeedsLayout()
        return self
    }
    
    @discardableResult
    public func subFormat<S: ValueOutputing>(_ formation: S) -> Self where S.OutputType == Format {
        view.py_setUnbinder(formation.safeBind(view, { (v, f) in
            v.regulator.subFormat = f
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }

}
