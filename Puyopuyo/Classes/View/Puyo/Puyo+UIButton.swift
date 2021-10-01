//
//  Puyo+UIButton.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/1.
//

import Foundation

@available(*, deprecated, message: "use -[text(:state:)")
public extension Puyo where T: UIButton {
    @discardableResult
    func title<S: Outputing>(_ title: S, state: UIControl.State = .normal) -> Self where S.OutputType: OptionalableValueType, S.OutputType.Wrap == String {
        return text(title, state: state)
    }

    @discardableResult
    func titleColor<S: Outputing>(_ color: S, state: UIControl.State = .normal) -> Self where S.OutputType: OptionalableValueType, S.OutputType.Wrap == UIColor {
        return textColor(color, state: state)
    }
}
