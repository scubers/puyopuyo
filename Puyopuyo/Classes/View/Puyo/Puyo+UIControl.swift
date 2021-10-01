//
//  Puyo+UIControl.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/3.
//

import Foundation

public extension Puyo where T: UIControl {
    @discardableResult
    func onControlEvent<I: Inputing>(_ event: UIControl.Event, _ input: I) -> Self where I.InputType == T {
        view.py_addAction(for: event) { control in
            input.input(value: control as! T)
        }
        return self
    }
}

// MARK: - Deprecated

@available(*, deprecated, message: "use onControlEvent(_:, _:)")
public extension Puyo where T: UIControl {
    @discardableResult
    func addWeakBind<Object: AnyObject>(to object: Object, for event: UIControl.Event, _ binding: @escaping (Object) -> (T) -> Void, unique: Bool = false) -> Self {
        bind(to: object, event: event) {
            binding($0)($1)
        }
    }

    @discardableResult
    func addWeakAction<Object: AnyObject>(to object: Object, for event: UIControl.Event, _ action: @escaping (Object, T) -> Void, unique: Bool = false) -> Self {
        bind(to: object, event: event) {
            action($0, $1)
        }
    }

    @discardableResult
    func addAction(for event: UIControl.Event, _ action: @escaping (T) -> Void, unique: Bool = false) -> Self {
        bind(event: event, unique: unique, input: Inputs { action($0) })
    }

    @discardableResult
    func bind(event: UIControl.Event, unique: Bool = false, action: @escaping (T) -> Void) -> Self {
        onControlEvent(event, Inputs(action))
    }

    @discardableResult
    func bind(event: UIControl.Event, unique: Bool = false, action: @escaping () -> Void) -> Self {
        bind(event: event, unique: unique, action: { _ in action() })
    }

    @discardableResult
    func bind<I: Inputing>(event: UIControl.Event, unique: Bool = false, input: I) -> Self where I.InputType == T {
        bind(event: event, unique: unique) { input.input(value: $0) }
    }

    @discardableResult
    func bind<O: AnyObject>(to object: O?, event: UIControl.Event, unique: Bool = false, action: @escaping (O, T) -> Void) -> Self {
        bind(event: event, unique: unique, input: Inputs { [weak object] in
            if let object = object {
                action(object, $0)
            }
        })
    }

    @discardableResult
    func bind<O: AnyObject>(to object: O?, event: UIControl.Event, unique: Bool = false, binding: @escaping (O) -> (T) -> Void) -> Self {
        bind(to: object, event: event, action: { binding($0)($1) })
    }
}
