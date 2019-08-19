//
//  PuyoLink+UITextField.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/3.
//

import Foundation

extension PuyoLink where T: UITextField {
    
    // MARK: - value
    @discardableResult
    public func textDelegate<S: Valuable>(_ delegate: S) -> Self where S.ValueType == UITextFieldDelegate? {
        view.py_setUnbinder(delegate.safeBind(view, { (v, s) in
            v.delegate = s
        }), for: #function)
        return self
    }
    
    // MARK: - state
    
    @discardableResult
    public func text<S: Valuable>(_ text: S) -> Self where S.ValueType == String? {
        view.py_setUnbinder(text.safeBind(view, { (v, a) in
            v.text = a
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func onText<S: Valuable & Outputable>(_ text: S) -> Self where S.ValueType == String?, S.OutputType == String? {
        view.py_setUnbinder(text.safeBind(view, { (v, a) in
            v.text = a
            v.py_setNeedsLayout()
        }), for: #function)
        addWeakAction(to: view, for: .editingChanged, { (_, v) in
            text.postValue(v.text)
        })
        return self
    }
    
    @discardableResult
    public func placeholder<S: Valuable>(_ text: S) -> Self where S.ValueType == String? {
        view.py_setUnbinder(text.safeBind(view, { (v, a) in
            v.placeholder = a
        }), for: #function)
        return self
    }
    
}
