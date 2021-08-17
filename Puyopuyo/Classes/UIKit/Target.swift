//
//  Target.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/30.
//

import Foundation

class PuyoTarget<T>: NSObject, Disposable {
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

extension UIControl {
    @discardableResult
    public func py_addAction(for event: UIControl.Event, _ block: @escaping (UIControl) -> Void) -> Disposable {
        let target = PuyoTarget<UIControl>(block)
        addTarget(target, action: #selector(PuyoTarget<UIControl>.targetAction(_:)), for: event)
        let Disposable = Disposables.create {
            self.removeTarget(target, action: #selector(PuyoTarget<UIControl>.targetAction(_:)), for: event)
        }
        addDisposable(target, for: "\(target)")
        return Disposable
    }
}

extension UIGestureRecognizer {
    @discardableResult
    public func py_addAction(_ block: @escaping (UIGestureRecognizer) -> Void) -> Disposable {
        let target = PuyoTarget<UIGestureRecognizer>(block)
        addTarget(target, action: #selector(PuyoTarget<UIGestureRecognizer>.targetAction(_:)))
        let Disposable = Disposables.create {
            self.removeTarget(target, action: #selector(PuyoTarget<UIGestureRecognizer>.targetAction(_:)))
        }
        addDisposable(target, for: "\(target)")
        return Disposable
    }
}
