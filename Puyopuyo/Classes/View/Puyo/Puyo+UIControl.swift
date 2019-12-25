//
//  Puyo+UIControl.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/3.
//

import Foundation

public extension Puyo where T: UIControl {
    @discardableResult
    func addWeakBind<Object: AnyObject>(to object: Object, for event: UIControl.Event, _ binding: @escaping (Object) -> (T) -> Void, unique: Bool = false) -> Self {
        return addAction(for: event, { [weak object] control in
            if let object = object {
                binding(object)(control)
            }
        }, unique: unique)
    }

    @discardableResult
    func addWeakAction<Object: AnyObject>(to object: Object, for event: UIControl.Event, _ action: @escaping (Object, T) -> Void, unique: Bool = false) -> Self {
        return addAction(for: event, { [weak object] control in
            if let object = object {
                action(object, control)
            }
        }, unique: unique)
    }

    @discardableResult
    func addAction(for event: UIControl.Event, _ action: @escaping (T) -> Void, unique: Bool = false) -> Self {
        let unbinder = view.py_addAction(for: event) { control in
            action(control as! T)
        }
        if unique {
            view.py_setUnbinder(unbinder, for: "py_unique_action_\(event)")
        }
        return self
    }

    @discardableResult
    func onEvent<I: Inputing>(_ event: UIControl.Event, _ input: I) -> Self where I.InputType == T {
        addWeakAction(to: view, for: event, { _, v in
            input.input(value: v)
        })
        return self
    }
}
