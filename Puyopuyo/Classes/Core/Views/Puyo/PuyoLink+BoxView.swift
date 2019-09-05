//
//  Puyo+ListBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/2.
//

import Foundation

// MARK: - BoxView
extension Puyo where T: BoxView {
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
    public func padding<O: Outputing>(_ padding: O) -> Self where O.OutputType == UIEdgeInsets {
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
    public func justifyContent<O: Outputing>(_ aligment: O) -> Self where O.OutputType == Aligment {
        view.py_setUnbinder(aligment.safeBind(view, { (v, a) in
            v.regulator.justifyContent = a
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func autoJudgeScroll(_ judge: Bool) -> Self {
        view.isScrollViewControl = judge
        setNeedsLayout()
        return self
    }
    
    @discardableResult
    public func isSelfPositionControl(_ control: Bool) -> Self {
        view.isSelfPositionControl = control
        setNeedsLayout()
        return self
    }

    @discardableResult
    public func borders(_ options: [BorderOptions]) -> Self {
        view.borders = Borders.all(Border(options: options))
        return self
    }
    
    @discardableResult
    public func topBorder(_ options: [BorderOptions]) -> Self {
        view.borders.top = Border(options: options)
        return self
    }
    
    @discardableResult
    public func leftBorder(_ options: [BorderOptions]) -> Self {
        view.borders.left = Border(options: options)
        return self
    }
    @discardableResult
    public func bottomBorder(_ options: [BorderOptions]) -> Self {
        view.borders.bottom = Border(options: options)
        return self
    }
    @discardableResult
    public func rightBorder(_ options: [BorderOptions]) -> Self {
        view.borders.right = Border(options: options)
        return self
    }
    
}

// MARK: - FlatBox
extension Puyo where T: FlatBox {
    
    @discardableResult
    public func space(_ space: CGFloat) -> Self {
        view.regulator.space = space
        setNeedsLayout()
        return self
    }
    
    @discardableResult
    public func space<O: Outputing>(_ space: O) -> Self where O.OutputType == CGFloat {
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
    public func format<O: Outputing>(_ formation: O) -> Self where O.OutputType == Format {
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
    public func direction<O: Outputing>(_ direction: O) -> Self where O.OutputType == Direction {
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
    public func reverse<O: Outputing>(_ reverse: O) -> Self where O.OutputType == Bool {
        view.py_setUnbinder(reverse.safeBind(view, { (v, r) in
            v.regulator.reverse = r
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
}

// MARK: - FlowBox
extension Puyo where T: FlowBox {
    
    @discardableResult
    public func arrangeCount(_ count: Int) -> Self {
        view.regulator.arrange = count
        setNeedsLayout()
        return self
    }
    
    @discardableResult
    public func arrangeCount<O: Outputing>(_ count: O) -> Self where O.OutputType == Int {
        view.py_setUnbinder(count.safeBind(view, { (v, c) in
            v.regulator.arrange = c
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func hSpace<O: Outputing>(_ space: O) -> Self where O.OutputType == CGFloat {
        view.py_setUnbinder(space.safeBind(view, { (v, s) in
            v.regulator.hSpace = s
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func vSpace<O: Outputing>(_ space: O) -> Self where O.OutputType == CGFloat {
        view.py_setUnbinder(space.safeBind(view, { (v, s) in
            v.regulator.vSpace = s
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func hFormat<O: Outputing>(_ formation: O) -> Self where O.OutputType == Format {
        view.py_setUnbinder(formation.safeBind(view, { (v, f) in
            v.regulator.hFormat = f
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func vFormat<O: Outputing>(_ formation: O) -> Self where O.OutputType == Format {
        view.py_setUnbinder(formation.safeBind(view, { (v, f) in
            v.regulator.vFormat = f
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }

}
