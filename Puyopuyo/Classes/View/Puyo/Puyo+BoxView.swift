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
    public func padding(all: CGFloatable? = nil, top: CGFloatable? = nil, left: CGFloatable? = nil, bottom: CGFloatable? = nil, right: CGFloatable? = nil) -> Self {
        if let all = all {
            view.regulator.padding = UIEdgeInsets(top: all.cgFloatValue, left: all.cgFloatValue, bottom: all.cgFloatValue, right: all.cgFloatValue)
        }
        if let top = top { view.regulator.padding.top = top.cgFloatValue }
        if let left = left { view.regulator.padding.left = left.cgFloatValue }
        if let bottom = bottom { view.regulator.padding.bottom = bottom.cgFloatValue }
        if let right = right { view.regulator.padding.right = right.cgFloatValue }
        view.py_setNeedsLayout()
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
    public func space<O: Outputing>(_ space: O) -> Self where O.OutputType: CGFloatable {
        view.py_setUnbinder(space.safeBind(view, { (v, s) in
            v.regulator.space = s.cgFloatValue
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
    public func arrangeCount<O: Outputing>(_ count: O) -> Self where O.OutputType == Int {
        view.py_setUnbinder(count.safeBind(view, { (v, c) in
            v.regulator.arrange = c
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func hSpace<O: Outputing>(_ space: O) -> Self where O.OutputType: CGFloatable {
        view.py_setUnbinder(space.safeBind(view, { (v, s) in
            v.regulator.hSpace = s.cgFloatValue
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func vSpace<O: Outputing>(_ space: O) -> Self where O.OutputType: CGFloatable {
        view.py_setUnbinder(space.safeBind(view, { (v, s) in
            v.regulator.vSpace = s.cgFloatValue
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
    public func hFormat(_ format: Format) -> Self {
        view.regulator.hFormat = format
        return self
    }
    
    @discardableResult
    public func vFormat(_ format: Format) -> Self {
        view.regulator.vFormat = format
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

extension Puyo where T: EventableView {
    @discardableResult
    public func onEventProduced<I: Inputing>(_ input: I) -> Self where I.InputType == T.EventType {
        _ = view.eventProducer.send(to: input)
        return self
    }
}

extension Puyo where T: StatefulView {
    @discardableResult
    public func viewState<O: Outputing>(_ output: O) -> Self where O.OutputType == T.StateType {
        _ = output.send(to: view.viewState)
        return self
    }
}
