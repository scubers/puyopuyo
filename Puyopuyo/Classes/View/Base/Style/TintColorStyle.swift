//
//  TintColorStyle.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/30.
//

import Foundation

public protocol TintColorStyleable {
    func applyTintColor(_ color: UIColor?, state: UIControl.State)
}

public class TintColorStyle: UIControlBaseStyle<UIColor?, TintColorStyleable> {
    public override func applyStyleable(_ styleable: TintColorStyleable) {
        styleable.applyTintColor(value, state: controlState)
    }
}
