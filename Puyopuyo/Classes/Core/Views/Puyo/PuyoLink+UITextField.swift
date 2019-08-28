//
//  Puyo+UITextField.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/3.
//

import Foundation

extension Puyo where T: UITextField {
    
    // MARK: - value
    @discardableResult
    public func textDelegate<S: Outputing>(_ delegate: S) -> Self where S.OutputType == UITextFieldDelegate? {
        view.py_setUnbinder(delegate.safeBind(view, { (v, s) in
            v.delegate = s
        }), for: #function)
        return self
    }
    
    // MARK: - state
    
    @discardableResult
    public func text<S: Outputing>(_ text: S) -> Self where S.OutputType == String? {
        view.py_setUnbinder(text.safeBind(view, { (v, a) in
            v.text = a
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func onText<S: Outputing & Inputing>(_ text: S) -> Self where S.OutputType == String?, S.InputType == String? {
        view.py_setUnbinder(text.safeBind(view, { (v, a) in
            v.text = a
            v.py_setNeedsLayout()
        }), for: #function)
        addWeakAction(to: view, for: .editingChanged, { (_, v) in
            text.input(value: v.text)
        })
        return self
    }
    
    @discardableResult
    public func placeholder<S: Outputing>(_ text: S) -> Self where S.OutputType == String? {
        view.py_setUnbinder(text.safeBind(view, { (v, a) in
            v.placeholder = a
        }), for: #function)
        return self
    }
    
}
