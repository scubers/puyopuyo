//
//  Puyo+UIButton.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/1.
//

import Foundation

public extension Puyo where T: UIButton {
    @discardableResult
    @available(*, deprecated, message: "use -[text(:state:)")
    func title<S: Outputing>(_ title: S, state: UIControl.State = .normal) -> Self where S.OutputType: OptionalableValueType, S.OutputType.Wrap == String {
        return text(title, state: state)
    }

    @discardableResult
    @available(*, deprecated, message: "use -[textColor(:state:)")
    func titleColor<S: Outputing>(_ color: S, state: UIControl.State = .normal) -> Self where S.OutputType: OptionalableValueType, S.OutputType.Wrap == UIColor {
        return textColor(color, state: state)
    }
}
