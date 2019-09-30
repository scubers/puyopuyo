//
//  TextStyle.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/28.
//

import Foundation
// MARK: - TextColor
public protocol TextColorStyleable {
    func applyTextColor(_ color: UIColor?, state: UIControl.State)
}

public class TextColorStyle: UIControlBaseStyle<UIColor?, TextColorStyleable> {
    public override func applyStyleable(_ styleable: TextColorStyleable) {
        styleable.applyTextColor(value, state: controlState)
    }
}
// MARK: - TextAligment
public protocol TextAligmentStyleable {
    func applyTextAligment(_ aligment: NSTextAlignment, state: UIControl.State)
}

public class TextAligmentStyle: UIControlBaseStyle<NSTextAlignment, TextAligmentStyleable> {
    public override func applyStyleable(_ styleable: TextAligmentStyleable) {
        styleable.applyTextAligment(value, state: controlState)
    }
}
// MARK: - TextLine
public protocol TextLinesStyleable {
    func applyNumberOfLine(_ line: Int)
}

public class TextLinsStyle: CommonValueStyle<Int, TextLinesStyleable> {
    public override func applyStyleable(_ styleable: TextLinesStyleable) {
        styleable.applyNumberOfLine(value)
    }
}
