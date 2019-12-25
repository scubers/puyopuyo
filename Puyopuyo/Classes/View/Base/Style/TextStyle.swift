//
//  TextStyle.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/28.
//

import Foundation

// MARK: - TextStyle
public protocol TextDecorable {
    func applyText(_ text: String?, state: UIControl.State)
    func applyAttrText(_ text: NSAttributedString?, state: UIControl.State)
}

// MARK: - TextColor

public protocol TextColorDecorable {
    func applyTextColor(_ color: UIColor?, state: UIControl.State)
}

public class TextColorStyle: UIControlBaseStyle<UIColor?, TextColorDecorable> {
    public override func applyDecorable(_ decorable: TextColorDecorable) {
        decorable.applyTextColor(value, state: controlState)
    }
}

// MARK: - TextAlignment

public protocol TextAlignmentDecorable {
    func applyTextAlignment(_ alignment: NSTextAlignment, state: UIControl.State)
}

public class TextAlignmentStyle: UIControlBaseStyle<NSTextAlignment, TextAlignmentDecorable> {
    public override func applyDecorable(_ decorable: TextAlignmentDecorable) {
        decorable.applyTextAlignment(value, state: controlState)
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
