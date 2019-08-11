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
        
        addWeakAction(to: view, for: .valueChanged) { (_, v) in
            state.postValue(v.isOn)
        }
        
        return self
    }
}
