//
//  TextStyle.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/28.
//

import Foundation

// MARK: - TextColor

public protocol TextColorDecorable {
    func applyTextColor(_ color: UIColor?, state: UIControl.State)
}

public class TextColorStyle: UIControlBaseStyle<UIColor?, TextColorDecorable> {
    public override func applyDecorable(_ decorable: TextColorDecorable) {
        decorable.applyTextColor(value, state: controlState)
    }
}

// MARK: - TextAligment

public protocol TextAligmentDecorable {
    func applyTextAligment(_ aligment: NSTextAlignment, state: UIControl.State)
}

public class TextAligmentStyle: UIControlBaseStyle<NSTextAlignment, TextAligmentDecorable> {
    public override func applyDecorable(_ decorable: TextAligmentDecorable) {
        decorable.applyTextAligment(value, state: controlState)
    }
}

// MARK: - TextLine

public protocol TextLinesDecorable {
    func applyNumberOfLine(_ line: Int)
}

public class TextLinsStyle: CommonValueStyle<Int, TextLinesDecorable> {
    public override func applyDecorable(_ decorable: TextLinesDecorable) {
        decorable.applyNumberOfLine(value)
    }
}
