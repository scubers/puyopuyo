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
        set(\T.isOn, state.asOutput().distinct())
            .onControlEvent(.valueChanged, state.asInput { $0.isOn })
    }
}
