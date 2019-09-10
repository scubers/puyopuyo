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
    
    /// 若TextField可能包裹，则每次输入都会重新布局，若非必要，不要设置
    @discardableResult
    public func resizeByContent() -> Self {
        addWeakAction(to: view, for: .editingChanged, { (v, _) in
            v.py_setNeedsLayoutIfMayBeWrap()
        })
        return self
    }
    
    @discardableResult
    public func text<S: Outputing>(_ text: S) -> Self where S.OutputType == String? {
        view.py_setUnbinder(text.safeBind(view, { (v, a) in
            guard a != v.text else { return }
            v.text = a
            v.py_setNeedsLayoutIfMayBeWrap()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func onText<S: Outputing & Inputing>(_ text: S) -> Self where S.OutputType == String?, S.InputType == String? {
        view.py_setUnbinder(text.safeBind(view, { (v, a) in
            guard a != v.text else { return }
            v.text = a
            v.py_setNeedsLayoutIfMayBeWrap()
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
    
    @discardableResult
    public func textColor<S: Outputing>(_ color: S) -> Self where S.OutputType == UIColor? {
        view.py_setUnbinder(color.safeBind(view, { (v, a) in
            v.textColor = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func font<S: Outputing>(_ font: S) -> Self where S.OutputType == UIFont {
        view.py_setUnbinder(font.safeBind(view, { (v, a) in
            v.font = a
            v.py_setNeedsLayoutIfMayBeWrap()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func textAligment<S: Outputing>(_ aligment: S) -> Self where S.OutputType == NSTextAlignment {
        view.py_setUnbinder(aligment.safeBind(view, { (v, a) in
            v.textAlignment = a
        }), for: #function)
        return self
    }
    
}
