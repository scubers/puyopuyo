//
//  Puyo+UIControl.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/3.
//

import Foundation

extension Puyo where T: UIControl {
    @discardableResult
    public func addWeakBind<Object: AnyObject>(to object: Object, for event: UIControl.Event, _ binding: @escaping (Object) -> (T) -> Void, unique: Bool = false) -> Self {
        return addAction(for: event, { [weak object] control in
            if let object = object {
                binding(object)(control)
            }
        }, unique: unique)
    }

    @discardableResult
    public func addWeakAction<Object: AnyObject>(to object: Object, for event: UIControl.Event, _ action: @escaping (Object, T) -> Void, unique: Bool = false) -> Self {
        return addAction(for: event, { [weak object] control in
            if let object = object {
                action(object, control)
            }
        }, unique: unique)
    }

    @discardableResult
    public func addAction(for event: UIControl.Event, _ action: @escaping (T) -> Void, unique: Bool = false) -> Self {
        let unbinder = view.py_addAction(for: event) { control in
            action(control as! T)
        }
        if unique {
            view.py_setUnbinder(unbinder, for: "py_unique_action_\(event)")
        }
        return self
    }

    @discardableResult
    public func onEvent<I: Inputing>(_ event: UIControl.Event, _ input: I) -> Self where I.InputType == T {
        addWeakAction(to: view, for: event, { _, v in
            input.input(value: v)
        })
        return self
    }
}

// class _PuyoTarget: NSObject, Unbinder {
//
//    var action: (UIControl) -> Void
//    init(_ action: @escaping (UIControl) -> Void) {
//        self.action = action
//    }
//
//    @objc func targetAction(_ btn: UIControl) {
//        action(btn)
//    }
//
//    func py_unbind() {
//
//    }
// }

// extension UIControl {
//    public func py_addAction(for event: UIControl.Event, _ block: @escaping (UIControl) -> Void) -> Unbinder {
//        let target = _PuyoTarget(block)
//        addTarget(target, action: #selector(_PuyoTarget.targetAction(_:)), for: event)
//        let unbinder = Unbinders.create {
//            self.removeTarget(target, action: #selector(_PuyoTarget.targetAction(_:)), for: event)
//        }
//        py_setUnbinder(target, for: "\(target)")
//        return unbinder
//    }
// }
