//
//  Target.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/30.
//

import Foundation

private class PuyoTarget<T>: NSObject, Disposer {
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
    func py_addAction(for event: UIControl.Event, _ block: @escaping (UIControl) -> Void) -> Disposer {
        let target = PuyoTarget<UIControl>(block)
        addTarget(target, action: #selector(PuyoTarget<UIControl>.targetAction(_:)), for: event)
        let disposable = Disposers.create {
            self.removeTarget(target, action: #selector(PuyoTarget<UIControl>.targetAction(_:)), for: event)
        }
        addDisposer(disposable, for: nil)
        return disposable
    }
}

public extension UIGestureRecognizer {
    @discardableResult
    func py_addAction(_ block: @escaping (UIGestureRecognizer) -> Void) -> Disposer {
        let target = PuyoTarget<UIGestureRecognizer>(block)
        addTarget(target, action: #selector(PuyoTarget<UIGestureRecognizer>.targetAction(_:)))
        let disposer = Disposers.create {
            self.removeTarget(target, action: #selector(PuyoTarget<UIGestureRecognizer>.targetAction(_:)))
        }
        addDisposer(disposer, for: nil)
        return disposer
    }
}

public extension UIView {
    @discardableResult
    func py_addTap(action: @escaping (UITapGestureRecognizer) -> Void) -> Disposer {
        let tap = Gesture()
        addGestureRecognizer(tap)
        return tap.py_addAction { g in
            action(g as! UITapGestureRecognizer)
        }
    }

    private class Gesture: UITapGestureRecognizer, UIGestureRecognizerDelegate {
        init() {
            super.init(target: nil, action: nil)
            delegate = self
            cancelsTouchesInView = false
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            if gestureRecognizer.view == otherGestureRecognizer.view {
                return true
            }
            return false
        }
    }
}
