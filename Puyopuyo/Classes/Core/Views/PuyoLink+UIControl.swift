//
//  PuyoLink+UIControl.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/3.
//

import Foundation

extension PuyoLink where T: UIControl {
    
    @discardableResult
    public func addWeakBind<Object: AnyObject>(to object: Object, for event: UIControl.Event, _ binding: @escaping (Object) -> (T) -> Void) -> Self {
        return self.addAction(for: event, { [weak object] (control) in
            if let object = object {
                binding(object)(control)
            }
        })
    }
    
    @discardableResult
    public func addWeakAction<Object: AnyObject>(to object: Object, for event: UIControl.Event, _ action: @escaping (Object, T) -> Void) -> Self {
        return self.addAction(for: event, { [weak object] (control) in
            if let object = object {
                action(object, control)
            }
        })
    }
    
    @discardableResult
    public func addAction(for event: UIControl.Event, _ action: @escaping (T) -> Void) -> Self {
        _ = view.py_addAction(for: event) { (control) in
            action(control as! T)
        }
        return self
    }
}


class _PuyoTarget: NSObject, Unbinder {
    
    var action: (UIControl) -> Void
    init(_ action: @escaping (UIControl) -> Void) {
        self.action = action
    }
    
    @objc func targetAction(_ btn: UIControl) {
        action(btn)
    }
    
    func py_unbind() {
        
    }
}

extension UIControl {
    public func py_addAction(for event: UIControl.Event, _ block: @escaping (UIControl) -> Void) -> Unbinder {
        let target = _PuyoTarget(block)
        addTarget(target, action: #selector(_PuyoTarget.targetAction(_:)), for: event)
        let unbinder = Unbinders.create {
            self.removeTarget(target, action: #selector(_PuyoTarget.targetAction(_:)), for: event)
        }
        py_setUnbinder(target, for: "\(target)")
        return unbinder
    }
}
