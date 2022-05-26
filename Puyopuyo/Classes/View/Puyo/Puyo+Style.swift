//
//  Puyo+Style.swift
//  Puyopuyo
//
//  Created by J on 2021/10/2.
//

import Foundation

public extension Puyo where T: UIView {
    @discardableResult
    func styleSheet<O: Outputing>(_ sheet: O) -> Self where O.OutputType: StyleSheet {
        sheet.safeBind(to: view) { v, s in
            v.py_styleSheet = s
        }
        return self
    }

    @discardableResult
    func styleSheet(_ sheet: StyleSheet) -> Self {
        set(\T.py_styleSheet, sheet)
    }

    @discardableResult
    func styles(_ styles: [Style]) -> Self {
        return styleSheet(StyleSheet(styles: styles))
    }

    @discardableResult
    func style(_ style: Style) -> Self {
        return styles([style])
    }
}
