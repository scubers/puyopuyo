//
//  TintColorStyle.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/30.
//

import Foundation

public protocol TintColorDecorable {
    func applyTintColor(_ color: UIColor?, state: UIControl.State)
}

public class TintColorStyle: UIControlBaseStyle<UIColor?, TintColorDecorable> {
    public override func applyDecorable(_ decorable: TintColorDecorable) {
        decorable.applyTintColor(value, state: controlState)
    }
}
