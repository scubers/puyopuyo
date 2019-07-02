//
//  PuyoLink+UITextField.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/3.
//

import Foundation

extension PuyoLink where T: UITextField {
    
    @discardableResult
    public func onTextChange(_ action: @escaping (String?) -> Void) -> Self {
        _ = view.py_action(for: .editingChanged) { (control) in
            action((control as! UITextField).text)
        }
        return self
    }
    
    @discardableResult
    public func onTextChange<S: Stateful>(_ action: S) -> Self where S.StateType == String {
        _ = view.py_action(for: .editingChanged) { (control) in
            let string = (control as! UITextField).text ?? ""
            action.py_change(string)
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
