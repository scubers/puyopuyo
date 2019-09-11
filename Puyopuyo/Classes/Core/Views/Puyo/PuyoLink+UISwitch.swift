//
//  Puyo+UISwitch.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/3.
//

import Foundation

extension Puyo where T: UISwitch {
    
    @discardableResult
    public func isOn<S: Outputing & Inputing>(_ state: S) -> Self where S.OutputType == S.InputType, S.InputType == Bool {
        state.safeBind(to: view, id: #function) { (v, a) in
            v.isOn = a
        }
        addWeakAction(to: view, for: .valueChanged, { (_, v) in
            state.input(value: v.isOn)
        })
        return self
    }
}
