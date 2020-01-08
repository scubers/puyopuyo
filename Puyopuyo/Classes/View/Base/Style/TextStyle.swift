//
//  TextStyle.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/28.
//

import Foundation

public class TextColorStyle: UIControlBaseStyle<UIColor?, TextColorDecorable> {
    public override func applyDecorable(_ decorable: TextColorDecorable) {
        decorable.applyTextColor(value, state: controlState)
    }
}

public class TextAlignmentStyle: UIControlBaseStyle<NSTextAlignment, TextAlignmentDecorable> {
    public override func applyDecorable(_ decorable: TextAlignmentDecorable) {
        decorable.applyTextAlignment(value, state: controlState)
    }
}

public class TextLinsStyle: CommonValueStyle<Int, TextLinesDecorable> {
    public override func applyDecorable(_ decorable: TextLinesDecorable) {
        decorable.applyNumberOfLine(value)
    }
}
