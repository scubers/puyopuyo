//
//  Puyo+UIControl.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/3.
//

import Foundation

public extension Puyo where T: UIControl {
    @discardableResult
    func isSelected<S: Outputing>(_ isSelected: S) -> Self where S.OutputType == Bool {
        bind(keyPath: \T.isSelected, isSelected)
    }

    @discardableResult
    func isEnabled<S: Outputing>(_ isEnabled: S) -> Self where S.OutputType == Bool {
        bind(keyPath: \T.isEnabled, isEnabled)
    }

    @discardableResult
    func isHighlighted<S: Outputing>(_ isHighlighted: S) -> Self where S.OutputType == Bool {
        bind(keyPath: \T.isHighlighted, isHighlighted)
    }

    @discardableResult
    func bind(event: UIControl.Event, unique: Bool = false, action: @escaping (T) -> Void) -> Self {
        let disposer = view.py_addAction(for: event) { control in
            action(control as! T)
        }
        if unique {
            view.addDisposer(disposer, for: "py_control_unique_action_\(event)")
        }
        return self
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

    @discardableResult
    func onEvent<I: Inputing>(_ event: UIControl.Event, _ input: I) -> Self where I.InputType == T {
        bind(event: event, input: input)
    }
}

// MARK: - Deprecated

public extension Puyo where T: UIControl {
    @discardableResult
    @available(*, deprecated, message: "use bind(event:unique:input)")
    func addWeakBind<Object: AnyObject>(to object: Object, for event: UIControl.Event, _ binding: @escaping (Object) -> (T) -> Void, unique: Bool = false) -> Self {
        bind(to: object, event: event) {
            binding($0)($1)
        }
    }

    @discardableResult
    @available(*, deprecated, message: "use bind(event:unique:input)")
    func addWeakAction<Object: AnyObject>(to object: Object, for event: UIControl.Event, _ action: @escaping (Object, T) -> Void, unique: Bool = false) -> Self {
        bind(to: object, event: event) {
            action($0, $1)
        }
    }

    @discardableResult
    @available(*, deprecated, message: "use bind(event:unique:action)")
    func addAction(for event: UIControl.Event, _ action: @escaping (T) -> Void, unique: Bool = false) -> Self {
        bind(event: event, unique: unique, input: Inputs { action($0) })
    }
}
