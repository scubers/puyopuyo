//
//  ButtonStyle.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/30.
//

import Foundation

// MARK: - TitleShadowColor

public protocol TitleShadowColorDecorable {
    func applyTitleShadowColor(_ color: UIColor?, state: UIControl.State)
}

public class TitleShadowColorStyle: UIControlBaseStyle<UIColor?, TitleShadowColorDecorable> {
    public override func applyDecorable(_ decorable: TitleShadowColorDecorable) {
        decorable.applyTitleShadowColor(value, state: controlState)
    }
}
