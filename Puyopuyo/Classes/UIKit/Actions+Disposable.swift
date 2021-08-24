//
//  Target.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/30.
//

import Foundation

private class PuyoTarget<T>: NSObject, Disposable {
    var action: (T) -> Void
    init(_ action: @escaping (T) -> Void) {
        self.action = action
    }

    @objc func targetAction(_ target: Any) {
        if let target = target as? T {
            action(target)
        }
    }

    func dispose() {}
}

public extension UIControl {
    @discardableResult
    func py_addAction(for event: UIControl.Event, _ block: @escaping (UIControl) -> Void) -> Disposable {
        let target = PuyoTarget<UIControl>(block)
        addTarget(target, action: #selector(PuyoTarget<UIControl>.targetAction(_:)), for: event)
        let Disposable = Disposables.create {
            self.removeTarget(target, action: #selector(PuyoTarget<UIControl>.targetAction(_:)), for: event)
        }
        addDisposable(target, for: UUID().description)
        return Disposable
    }
}

public extension UIGestureRecognizer {
    @discardableResult
    func py_addAction(_ block: @escaping (UIGestureRecognizer) -> Void) -> Disposable {
        let target = PuyoTarget<UIGestureRecognizer>(block)
        addTarget(target, action: #selector(PuyoTarget<UIGestureRecognizer>.targetAction(_:)))
        let Disposable = Disposables.create {
            self.removeTarget(target, action: #selector(PuyoTarget<UIGestureRecognizer>.targetAction(_:)))
        }
        addDisposable(target, for: UUID().description)
        return Disposable
    }
}

public extension UIView {
    @discardableResult
    func py_setTap(action: @escaping (UITapGestureRecognizer) -> Void) -> Disposable {
        let tap = UITapGestureRecognizer()
        let Disposable = tap.py_addAction { g in
            action(g as! UITapGestureRecognizer)
        }
        addGestureRecognizer(tap)
        addDisposable(Disposable, for: #function)
        return Disposable
    }
}
