//
//  PuyoLink+UISwitch.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/3.
//

import Foundation

extension PuyoLink where T: UISwitch {
    
    @discardableResult
    public func isOn<S: Valuable & Outputable>(_ state: S) -> Self where S.ValueType == Bool, S.OutputType == Bool {
        view.py_setUnbinder(state.safeBind(view, { (v, a) in
            v.isOn = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func onValueChange(_ action: @escaping (Bool) -> Void) -> Self {
        _ = view.py_action(for: .valueChanged) { (control) in
            action((control as! T).isOn)
        }
        return self
    }
    
    @discardableResult
    public func onValueChange<S: Outputable>(_ action: S) -> Self where S.OutputType == Bool {
        _ = view.py_action(for: .valueChanged) { (control) in
            let isOn = (control as! T).isOn
            action.postValue(isOn)
        }
        return self
    }
    
}
