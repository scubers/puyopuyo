//
//  PuyoLink+UISwitch.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/3.
//

import Foundation

extension PuyoLink where T: UISwitch {
    
    @discardableResult
    public func onValueChange(_ action: @escaping (Bool) -> Void) -> Self {
        _ = view.py_action(for: .valueChanged) { (control) in
            action((control as! T).isOn)
        }
        return self
    }
    
    @discardableResult
    public func onValueChange<S: Stateful>(_ action: S) -> Self where S.StateType == Bool {
        _ = view.py_action(for: .valueChanged) { (control) in
            let isOn = (control as! T).isOn
            action.py_change(isOn)
        }
        return self
    }
    
}
