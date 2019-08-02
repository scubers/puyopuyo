//
//  PuyoLink+UITextField.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/3.
//

import Foundation

extension PuyoLink where T: UITextField {
    
    // MARK: - value
    
    // MARK: - state
    
    @discardableResult
    public func placeholder<S: Valuable>(_ text: S) -> Self where S.ValueType == String? {
        view.py_setUnbinder(text.safeBind(view, { (v, a) in
            v.placeholder = a
        }), for: #function)
        return self
    }
    @discardableResult
    public func textState<S: Valuable & Outputable>(_ text: S) -> Self where S.ValueType == String, S.OutputType == String {
        onTextChange(text)
        view.py_setUnbinder(text.safeBind(view, { (v, a) in
            v.text = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func onTextChange(_ action: @escaping (String?) -> Void) -> Self {
        _ = view.py_action(for: .editingChanged) { (control) in
            action((control as! UITextField).text)
        }
        return self
    }
    
    @discardableResult
    public func onTextChange<S: Outputable>(_ action: S) -> Self where S.OutputType == String {
        _ = view.py_action(for: .editingChanged) { (control) in
            let string = (control as! UITextField).text ?? ""
            action.postValue(string)
        }
        return self
    }
    
    @discardableResult
    public func onBeginEditing(_ action: @escaping (T) -> Void) -> Self {
        _ = view.py_action(for: .editingDidBegin) { (control) in
            action((control as! T))
        }
        return self
    }
    
    @discardableResult
    public func onEndEditing(_ action: @escaping (T) -> Void) -> Self {
        _ = view.py_action(for: [.editingDidEnd, .editingDidEndOnExit]) { (control) in
            action((control as! T))
        }
        return self
    }
}
