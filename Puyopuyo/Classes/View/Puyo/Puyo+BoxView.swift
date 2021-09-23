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
    func padding(all: CGFloatable? = nil,
                 horz: CGFloatable? = nil,
                 vert: CGFloatable? = nil,
                 top: CGFloatable? = nil,
                 left: CGFloatable? = nil,
                 bottom: CGFloatable? = nil,
                 right: CGFloatable? = nil) -> Self
    {
        PuyoHelper.padding(for: view, all: all?.cgFloatValue, horz: horz?.cgFloatValue, vert: vert?.cgFloatValue, top: top?.cgFloatValue, left: left?.cgFloatValue, bottom: bottom?.cgFloatValue, right: right?.cgFloatValue)
        return self
    }

    @discardableResult
    func padding<S: Outputing>(all: S? = nil, horz: S? = nil, vert: S? = nil, top: S? = nil, left: S? = nil, bottom: S? = nil, right: S? = nil) -> Self where S.OutputType: CGFloatable {
        if let s = all {
            s.safeBind(to: view) { v, a in
                PuyoHelper.padding(for: v, all: a.cgFloatValue)
            }
        }
        if let s = top {
            s.safeBind(to: view) { v, a in
                PuyoHelper.padding(for: v, top: a.cgFloatValue)
            }
        }
        if let s = horz {
            s.safeBind(to: view) { v, a in
                PuyoHelper.padding(for: v, horz: a.cgFloatValue)
            }
        }
        if let s = vert {
            s.safeBind(to: view) { v, a in
                PuyoHelper.padding(for: v, vert: a.cgFloatValue)
            }
        }
        if let s = left {
            s.safeBind(to: view) { v, a in
                PuyoHelper.padding(for: v, left: a.cgFloatValue)
            }
        }
        if let s = bottom {
            s.safeBind(to: view) { v, a in
                PuyoHelper.padding(for: v, bottom: a.cgFloatValue)
            }
        }
        if let s = right {
            s.safeBind(to: view) { v, a in
                PuyoHelper.padding(for: v, right: a.cgFloatValue)
            }
        }
        return self
    }

    @discardableResult
    func padding<O: Outputing>(_ padding: O) -> Self where O.OutputType == UIEdgeInsets {
        bind(keyPath: \T.regulator.padding, padding)
    }

    @discardableResult
    func justifyContent(_ alignment: Alignment) -> Self {
        bind(keyPath: \T.regulator.justifyContent, alignment)
    }

    @discardableResult
    func justifyContent<O: Outputing>(_ alignment: O) -> Self where O.OutputType == Alignment {
        bind(keyPath: \T.regulator.justifyContent, alignment)
    }

    @discardableResult
    func autoJudgeScroll(_ judge: Bool) -> Self {
        bind(keyPath: \T.control.isScrollViewControl, judge)
    }

    @discardableResult
    func isCenterControl(_ control: Bool) -> Self {
        bind(keyPath: \T.control.isCenterControl, control)
    }

    @discardableResult
    func isSizeControl(_ control: Bool) -> Self {
        bind(keyPath: \T.control.isSizeControl, control)
    }

    @discardableResult
    func borders(_ options: [BorderOptions]) -> Self {
        view.control.borders = Borders.all(Border(options: options))
        return self
    }

    @discardableResult
    func topBorder(_ options: [BorderOptions]) -> Self {
        view.control.borders.top = Border(options: options)
        return self
    }

    @discardableResult
    func leftBorder(_ options: [BorderOptions]) -> Self {
        view.control.borders.left = Border(options: options)
        return self
    }

    @discardableResult
    func bottomBorder(_ options: [BorderOptions]) -> Self {
        view.control.borders.bottom = Border(options: options)
        return self
    }

    @discardableResult
    func rightBorder(_ options: [BorderOptions]) -> Self {
        view.control.borders.right = Border(options: options)
        return self
    }
}

// MARK: - Statful & Eventable

public extension Puyo where T: Eventable {
    @discardableResult
    func onEvent<I: Inputing>(_ input: I) -> Self where I.InputType == T.EmitterType.OutputType {
        let disposer = view.emmiter.send(to: input)
        if let v = view as? DisposableBag {
            disposer.dispose(by: v)
        }
        return self
    }

    @discardableResult
    func onEvent(_ event: @escaping (T.EmitterType.OutputType) -> Void) -> Self {
        onEvent(Inputs(event))
    }

    @discardableResult
    func onEvent<O: AnyObject>(to: O?, _ event: @escaping (O, T.EmitterType.OutputType) -> Void) -> Self {
        onEvent(Inputs { [weak to] v in
            if let to = to {
                event(to, v)
            }
        })
    }
}

public extension Puyo where T: Stateful {
    @discardableResult
    func viewState<O: Outputing>(_ output: O, unbindable: DisposableBag) -> Self where O.OutputType == T.StateType.OutputType {
        output.send(to: view.viewState).dispose(by: unbindable)
        return self
    }
}

public extension Puyo where T: Stateful, T: NSObject {
    @discardableResult
    func viewState<O: Outputing>(_ output: O) -> Self where O.OutputType == T.StateType.OutputType {
        output.send(to: view.viewState).dispose(by: view)
        return self
    }
}

// MARK: - Delegatable & DataSourceable

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
