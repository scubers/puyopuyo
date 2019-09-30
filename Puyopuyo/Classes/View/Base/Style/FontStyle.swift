//
//  FontStyle.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/28.
//

import Foundation

// MARK: - Font style
public protocol FontStyleable {
    func applyFont(_ font: UIFont?)
}

extension UIFont: Style {
    public func apply(to styleable: Styleable) {
        guard let view = styleable as? FontStyleable else { return }
        view.applyFont(self)
    }
}

extension Styles {
    @objc public static var systemFont: Styles {
        return Styles(style: UIFont.systemFont(ofSize: UIFont.systemFontSize))
    }
}
