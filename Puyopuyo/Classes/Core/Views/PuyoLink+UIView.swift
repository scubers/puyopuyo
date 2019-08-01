//
//  PuyoLink+UIView.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/1.
//

import Foundation

extension PuyoLink where T: UIView {
    @discardableResult
    public func backgroundColor<S: Stateful>(_ color: S) -> Self where S.StateType == Optional<UIColor> {
        view.py_setUnbinder(color.safeBind(view, { (v, a) in
            v.backgroundColor = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func contentMode<S: Stateful>(_ mode: S) -> Self where S.StateType == UIView.ContentMode {
        view.py_setUnbinder(mode.safeBind(view, { (v, a) in
            v.contentMode = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func clipToBounds<S: Stateful>(_ clip: S) -> Self where S.StateType == Bool {
        view.py_setUnbinder(clip.safeBind(view, { (v, a) in
            v.clipsToBounds = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func cornerRadius<S: Stateful>(_ radius: S) -> Self where S.StateType == CGFloat {
        view.py_setUnbinder(radius.safeBind(view, { (v, a) in
            v.layer.cornerRadius = a
            v.clipsToBounds = true
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func borderWidth<S: Stateful>(_ width: S) -> Self where S.StateType == CGFloat {
        view.py_setUnbinder(width.safeBind(view, { (v, a) in
            v.layer.borderWidth = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func borderColor<S: Stateful>(_ color: S) -> Self where S.StateType == UIColor? {
        view.py_setUnbinder(color.safeBind(view, { (v, a) in
            v.layer.borderColor = a?.cgColor
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func alpha<S: Stateful>(_ alpha: S) -> Self where S.StateType == CGFloat {
        view.py_setUnbinder(alpha.safeBind(view, { (v, a) in
            v.alpha = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func userInteractionEnabled<S: Stateful>(_ enabled: S) -> Self where S.StateType == Bool {
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
