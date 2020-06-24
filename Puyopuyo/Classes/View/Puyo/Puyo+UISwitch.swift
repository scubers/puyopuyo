//
//  Puyo+UISwitch.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/3.
//

import Foundation

public extension Puyo where T: UISwitch {
    @discardableResult
    func isOn<S: Outputing & Inputing>(_ state: S) -> Self where S.OutputType == S.InputType, S.InputType == Bool {
        state.safeBind(to: view, id: #function) { v, a in
            v.isOn = a
        }
        bind(to: view, event: .valueChanged) { (_, v) in
            state.input(value: v.isOn)
        }
        return self
    }
    
    @discardableResult
    func isOnValue<S: Outputing>(_ state: S) -> Self where S.OutputType == Bool {
        state.safeBind(to: view, id: #function) { v, a in
            v.isOn = a
        }
        return self
    }
}
