//
//  ButtonStyle.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/28.
//

import Foundation

public class PaddingStyle: CommonValueStyle<UIEdgeInsets, PaddingDecorable> {
    public override func applyDecorable(_ v: PaddingDecorable) {
        v.applyPadding(value)
    }
}
