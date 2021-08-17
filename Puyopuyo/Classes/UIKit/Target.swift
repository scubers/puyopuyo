//
//  Target.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/30.
//

import Foundation

class PuyoTarget<T>: NSObject, Unbinder {
    var action: (T) -> Void
    init(_ action: @escaping (T) -> Void) {
        self.action = action
    }

    @objc func targetAction(_ target: Any) {
        if let target = target as? T {
            action(target)
        }
    }

    func py_unbind() {}
}

extension UIControl {
    @discardableResult
    public func py_addAction(for event: UIControl.Event, _ block: @escaping (UIControl) -> Void) -> Unbinder {
        let target = PuyoTarget<UIControl>(block)
        addTarget(target, action: #selector(PuyoTarget<UIControl>.targetAction(_:)), for: event)
        let unbinder = Unbinders.create {
            self.removeTarget(target, action: #selector(PuyoTarget<UIControl>.targetAction(_:)), for: event)
        }
        py_setUnbinder(target, for: "\(target)")
        return unbinder
    }
}

extension UIGestureRecognizer {
    @discardableResult
    public func py_addAction(_ block: @escaping (UIGestureRecognizer) -> Void) -> Unbinder {
        let target = PuyoTarget<UIGestureRecognizer>(block)
        addTarget(target, action: #selector(PuyoTarget<UIGestureRecognizer>.targetAction(_:)))
        let unbinder = Unbinders.create {
            self.removeTarget(target, action: #selector(PuyoTarget<UIGestureRecognizer>.targetAction(_:)))
        }
        py_setUnbinder(target, for: "\(target)")
        return unbinder
    }
}
