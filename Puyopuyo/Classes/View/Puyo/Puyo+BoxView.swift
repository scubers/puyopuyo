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
        bind(keyPath: \T.boxHelper.animator, animator)
    }

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
        bind(keyPath: \T.boxHelper.isScrollViewControl, judge)
    }

    @discardableResult
    func isCenterControl(_ control: Bool) -> Self {
        bind(keyPath: \T.boxHelper.isCenterControl, control)
    }

    @discardableResult
    func isSizeControl(_ control: Bool) -> Self {
        bind(keyPath: \T.boxHelper.isSizeControl, control)
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
        bind(keyPath: \T.regulator.space, space.mapCGFloat())
    }

    @discardableResult
    func format(_ formation: Format) -> Self {
        bind(keyPath: \T.regulator.format, formation)
    }

    @discardableResult
    func format<O: Outputing>(_ formation: O) -> Self where O.OutputType == Format {
        bind(keyPath: \T.regulator.format, formation)
    }

    @discardableResult
    func direction(_ direction: Direction) -> Self {
        bind(keyPath: \T.regulator.direction, direction)
    }

    @discardableResult
    func direction<O: Outputing>(_ direction: O) -> Self where O.OutputType == Direction {
        bind(keyPath: \T.regulator.direction, direction)
    }

    @discardableResult
    func reverse<O: Outputing>(_ reverse: O) -> Self where O.OutputType == Bool {
        bind(keyPath: \T.regulator.reverse, reverse)
    }
}

// MARK: - FlowBox

public extension Puyo where T: Boxable & UIView, T.RegulatorType: FlowRegulator {
    @discardableResult
    func arrangeCount<O: Outputing>(_ count: O) -> Self where O.OutputType == Int {
        bind(keyPath: \T.regulator.arrange, count)
    }

    @discardableResult
    func hSpace<O: Outputing>(_ space: O) -> Self where O.OutputType: CGFloatable {
        bind(keyPath: \T.regulator.hSpace, space.mapCGFloat())
    }

    @discardableResult
    func vSpace<O: Outputing>(_ space: O) -> Self where O.OutputType: CGFloatable {
        bind(keyPath: \T.regulator.vSpace, space.mapCGFloat())
        return self
    }

    @discardableResult
    func hFormat<O: Outputing>(_ formation: O) -> Self where O.OutputType == Format {
        bind(keyPath: \T.regulator.hFormat, formation)
    }

    @discardableResult
    func hFormat(_ format: Format) -> Self {
        bind(keyPath: \T.regulator.hFormat, format)
    }

    @discardableResult
    func vFormat(_ format: Format) -> Self {
        bind(keyPath: \T.regulator.vFormat, format)
    }

    @discardableResult
    func vFormat<O: Outputing>(_ formation: O) -> Self where O.OutputType == Format {
        bind(keyPath: \T.regulator.vFormat, formation)
    }

    @discardableResult
    func stretchRows<O: Outputing>(_ stretch: O) -> Self where O.OutputType == Bool {
        bind(keyPath: \T.regulator.stretchRows, stretch)
    }
}

// MARK: - Statful & Eventable

public extension Puyo where T: Eventable {
    @discardableResult
    func onEventProduced<I: Inputing>(_ input: I) -> Self where I.InputType == T.EventType {
        let disposer = view.eventProducer.send(to: input)
        if let v = view as? NSObject {
            v.addDisposer(disposer, for: nil)
        }
        return self
    }

    @discardableResult
    func onEventProduced<Object: AnyObject>(to: Object, _ action: @escaping (Object, T.EventType) -> Void) -> Self {
        let disposer = view.eventProducer.outputing { [weak to] event in
            if let to = to {
                action(to, event)
            }
        }
        if let v = view as? DisposableBag {
            v.addDisposer(disposer, for: nil)
        }
        return self
    }
}

public extension Puyo where T: Stateful {
    @discardableResult
    func viewState<O: Outputing>(_ output: O, unbindable: DisposableBag) -> Self where O.OutputType == T.StateType {
        output.send(to: view.viewState).dispose(by: unbindable)
        return self
    }
}

public extension Puyo where T: Stateful, T: NSObject {
    @discardableResult
    func viewState<O: Outputing>(_ output: O) -> Self where O.OutputType == T.StateType {
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
