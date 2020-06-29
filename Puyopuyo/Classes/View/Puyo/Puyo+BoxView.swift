//
//  Puyo+ListBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/2.
//

import Foundation

// MARK: - BoxView

public extension Puyo where T: Boxable & UIView {
    @discardableResult
    func animator(_ animator: Animator) -> Self {
        view.boxHelper.animator = animator
        return self
    }

    @discardableResult
    func animator<O: Outputing>(_ animator: O) -> Self where O.OutputType == Animator {
        animator.safeBind(to: view, id: #function) { v, a in
            v.boxHelper.animator = a
        }
        return self
    }

    @discardableResult
    func padding(all: CGFloatable? = nil,
                 horz: CGFloatable? = nil,
                 vert: CGFloatable? = nil,
                 top: CGFloatable? = nil,
                 left: CGFloatable? = nil,
                 bottom: CGFloatable? = nil,
                 right: CGFloatable? = nil) -> Self {
        PuyoHelper.padding(for: view, all: all?.cgFloatValue, horz: horz?.cgFloatValue, vert: vert?.cgFloatValue, top: top?.cgFloatValue, left: left?.cgFloatValue, bottom: bottom?.cgFloatValue, right: right?.cgFloatValue)
        return self
    }

    @discardableResult
    func padding<S: Outputing>(all: S? = nil, horz: S? = nil, vert: S? = nil, top: S? = nil, left: S? = nil, bottom: S? = nil, right: S? = nil) -> Self where S.OutputType: CGFloatable {
        if let s = all {
            view.py_setUnbinder(s.catchObject(view, { v, a in
                PuyoHelper.padding(for: v, all: a.cgFloatValue)
            }), for: "\(#function)_all")
        }
        if let s = top {
            view.py_setUnbinder(s.catchObject(view, { v, a in
                PuyoHelper.padding(for: v, top: a.cgFloatValue)
            }), for: "\(#function)_top")
        }
        if let s = horz {
            view.py_setUnbinder(s.catchObject(view, { v, a in
                PuyoHelper.padding(for: v, horz: a.cgFloatValue)
            }), for: "\(#function)_horz")
        }
        if let s = vert {
            view.py_setUnbinder(s.catchObject(view, { v, a in
                PuyoHelper.padding(for: v, vert: a.cgFloatValue)
            }), for: "\(#function)_vert")
        }
        if let s = left {
            view.py_setUnbinder(s.catchObject(view, { v, a in
                PuyoHelper.padding(for: v, left: a.cgFloatValue)
            }), for: "\(#function)_left")
        }
        if let s = bottom {
            view.py_setUnbinder(s.catchObject(view, { v, a in
                PuyoHelper.padding(for: v, bottom: a.cgFloatValue)
            }), for: "\(#function)_bottom")
        }
        if let s = right {
            view.py_setUnbinder(s.catchObject(view, { v, a in
                PuyoHelper.padding(for: v, right: a.cgFloatValue)
            }), for: "\(#function)_right")
        }
        return self
    }

    @discardableResult
    func padding<O: Outputing>(_ padding: O) -> Self where O.OutputType == UIEdgeInsets {
        view.py_setUnbinder(padding.catchObject(view, { v, i in
            v.regulator.padding = i
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }

    @discardableResult
    func justifyContent(_ alignment: Alignment) -> Self {
        view.regulator.justifyContent = alignment
        setNeedsLayout()
        return self
    }

    @discardableResult
    func justifyContent<O: Outputing>(_ alignment: O) -> Self where O.OutputType == Alignment {
        view.py_setUnbinder(alignment.catchObject(view, { v, a in
            v.regulator.justifyContent = a
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }

    @discardableResult
    func autoJudgeScroll(_ judge: Bool) -> Self {
        view.boxHelper.isScrollViewControl = judge
        setNeedsLayout()
        return self
    }

    @discardableResult
    func isCenterControl(_ control: Bool) -> Self {
        view.boxHelper.isCenterControl = control
        setNeedsLayout()
        return self
    }
    
    @discardableResult
    func isSizeControl(_ control: Bool) -> Self {
        view.boxHelper.isSizeControl = control
        setNeedsLayout()
        return self
    }

    @discardableResult
    func borders(_ options: [BorderOptions]) -> Self {
        view.boxHelper.borders = Borders.all(Border(options: options))
        return self
    }

    @discardableResult
    func topBorder(_ options: [BorderOptions]) -> Self {
        view.boxHelper.borders.top = Border(options: options)
        return self
    }

    @discardableResult
    func leftBorder(_ options: [BorderOptions]) -> Self {
        view.boxHelper.borders.left = Border(options: options)
        return self
    }

    @discardableResult
    func bottomBorder(_ options: [BorderOptions]) -> Self {
        view.boxHelper.borders.bottom = Border(options: options)
        return self
    }

    @discardableResult
    func rightBorder(_ options: [BorderOptions]) -> Self {
        view.boxHelper.borders.right = Border(options: options)
        return self
    }
}

// MARK: - FlatBox

public extension Puyo where T: Boxable & UIView, T.RegulatorType: FlatRegulator {
    @discardableResult
    func space<O: Outputing>(_ space: O) -> Self where O.OutputType: CGFloatable {
        view.py_setUnbinder(space.catchObject(view, { v, s in
            v.regulator.space = s.cgFloatValue
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }

    @discardableResult
    func format(_ formation: Format) -> Self {
        view.regulator.format = formation
        setNeedsLayout()
        return self
    }

    @discardableResult
    func format<O: Outputing>(_ formation: O) -> Self where O.OutputType == Format {
        view.py_setUnbinder(formation.catchObject(view, { v, f in
            v.regulator.format = f
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }

    @discardableResult
    func direction(_ direction: Direction) -> Self {
        view.regulator.direction = direction
        setNeedsLayout()
        return self
    }

    @discardableResult
    func direction<O: Outputing>(_ direction: O) -> Self where O.OutputType == Direction {
        view.py_setUnbinder(direction.catchObject(view, { v, d in
            v.regulator.direction = d
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }

    @discardableResult
    func reverse<O: Outputing>(_ reverse: O) -> Self where O.OutputType == Bool {
        view.py_setUnbinder(reverse.catchObject(view, { v, r in
            v.regulator.reverse = r
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
}

// MARK: - FlowBox

public extension Puyo where T: Boxable & UIView, T.RegulatorType: FlowRegulator {
    @discardableResult
    func arrangeCount<O: Outputing>(_ count: O) -> Self where O.OutputType == Int {
        view.py_setUnbinder(count.catchObject(view, { v, c in
            v.regulator.arrange = c
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }

    @discardableResult
    func hSpace<O: Outputing>(_ space: O) -> Self where O.OutputType: CGFloatable {
        view.py_setUnbinder(space.catchObject(view, { v, s in
            v.regulator.hSpace = s.cgFloatValue
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }

    @discardableResult
    func vSpace<O: Outputing>(_ space: O) -> Self where O.OutputType: CGFloatable {
        view.py_setUnbinder(space.catchObject(view, { v, s in
            v.regulator.vSpace = s.cgFloatValue
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }

    @discardableResult
    func hFormat<O: Outputing>(_ formation: O) -> Self where O.OutputType == Format {
        view.py_setUnbinder(formation.catchObject(view, { v, f in
            v.regulator.hFormat = f
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }

    @discardableResult
    func hFormat(_ format: Format) -> Self {
        view.regulator.hFormat = format
        return self
    }

    @discardableResult
    func vFormat(_ format: Format) -> Self {
        view.regulator.vFormat = format
        return self
    }

    @discardableResult
    func vFormat<O: Outputing>(_ formation: O) -> Self where O.OutputType == Format {
        view.py_setUnbinder(formation.catchObject(view, { v, f in
            v.regulator.vFormat = f
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }

    @discardableResult
    func stretchRows<O: Outputing>(_ stretch: O) -> Self where O.OutputType == Bool {
        stretch.safeBind(to: view, id: #function) { v, a in
            v.regulator.stretchRows = a
            v.py_setNeedsLayout()
        }
        return self
    }
}

public extension Puyo where T: Eventable {
    @discardableResult
    func onEventProduced<I: Inputing>(_ input: I) -> Self where I.InputType == T.EventType {
        let unbinder = view.eventProducer.send(to: input)
        if let v = view as? NSObject {
            v.py_setUnbinder(unbinder, for: UUID().description)
        }
        return self
    }

    @discardableResult
    func onEventProduced<Object: AnyObject>(to: Object, _ action: @escaping (Object, T.EventType) -> Void) -> Self {
        let unbinder = view.eventProducer.outputing { [weak to] event in
            if let to = to {
                action(to, event)
            }
        }
        if let v = view as? NSObject {
            v.py_setUnbinder(unbinder, for: UUID().description)
        }
        return self
    }
}

public extension Puyo where T: Stateful {
    @discardableResult
    func viewState<O: Outputing>(_ output: O, unbindable: UnbinderBag) -> Self where O.OutputType == T.StateType {
        output.send(to: view.viewState).unbind(by: unbindable)
        return self
    }
    
    @discardableResult
    func stateChange<O: Outputing, R, V>(_ output: O, to kp: WritableKeyPath<R, V>, unbindable: UnbinderBag) -> Self where O.OutputType == V, R == T.StateType {
        output.outputing { [weak view] in
            view?.viewState.value[keyPath: kp] = $0
        }.unbind(by: unbindable)
        return self
    }
}

public extension Puyo where T: Stateful, T: NSObject {
    @discardableResult
    func viewState<O: Outputing>(_ output: O) -> Self where O.OutputType == T.StateType {
        output.send(to: view.viewState).unbind(by: view)
        return self
    }
    
    @discardableResult
    func stateChange<O: Outputing, R, V>(_ output: O, to kp: WritableKeyPath<R, V>) -> Self where O.OutputType == V, R == T.StateType {
        output.outputing { [weak view] in
            view?.viewState.value[keyPath: kp] = $0
        }.unbind(by: view)
        return self
    }
    
    @discardableResult
    func setState(_ action: (inout T.StateType) -> Void) -> Self {
        view.viewState.setState(action)
        return self
    }
}

public extension Puyo where T: Delegatable {
    @discardableResult
    func setDelegate(_ delegate: T.DelegateType, retained: Bool = false) -> Self {
        view.setDelegate(delegate, retained: retained)
        return self
    }
}

public extension Puyo where T: DataSourceable {
    @discardableResult
    func setDataSource(_ dataSource: T.DataSourceType, retained: Bool = false) -> Self {
        view.setDataSource(dataSource, retained: retained)
        return self
    }
}
