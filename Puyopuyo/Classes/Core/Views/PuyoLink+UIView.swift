//
//  PuyoLink+UIView.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/1.
//

import Foundation

extension PuyoLink where T: UIView {
    
    @discardableResult
    public func backgroundColor<S: Valuable>(_ color: S) -> Self where S.ValueType == UIColor? {
        view.py_setUnbinder(color.safeBind(view, { (v, a) in
            v.backgroundColor = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func contentMode<S: Valuable>(_ mode: S) -> Self where S.ValueType == UIView.ContentMode {
        view.py_setUnbinder(mode.safeBind(view, { (v, a) in
            v.contentMode = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func clipToBounds<S: Valuable>(_ clip: S) -> Self where S.ValueType == Bool {
        view.py_setUnbinder(clip.safeBind(view, { (v, a) in
            v.clipsToBounds = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func cornerRadius<S: Valuable>(_ radius: S) -> Self where S.ValueType == CGFloat {
        view.py_setUnbinder(radius.safeBind(view, { (v, a) in
            v.layer.cornerRadius = a
            v.clipsToBounds = true
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func borderWidth<S: Valuable>(_ width: S) -> Self where S.ValueType == CGFloat {
        view.py_setUnbinder(width.safeBind(view, { (v, a) in
            v.layer.borderWidth = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func borderColor<S: Valuable>(_ color: S) -> Self where S.ValueType == UIColor? {
        view.py_setUnbinder(color.safeBind(view, { (v, a) in
            v.layer.borderColor = a?.cgColor
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func alpha<S: Valuable>(_ alpha: S) -> Self where S.ValueType == CGFloat {
        view.py_setUnbinder(alpha.safeBind(view, { (v, a) in
            v.alpha = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func userInteractionEnabled<S: Valuable>(_ enabled: S) -> Self where S.ValueType == Bool {
        view.py_setUnbinder(enabled.safeBind(view, { (v, a) in
            v.isUserInteractionEnabled = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func tag(_ tag: Int) -> Self {
        view.tag = tag
        return self
    }
}
