//
//  FontStyle.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/28.
//

import Foundation

// MARK: - Font style

public protocol FontDecorable {
    func applyFont(_ font: UIFont?)
}

extension UIFont: Style {
    public func apply(to decorable: Decorable) {
        guard let view = decorable as? FontDecorable else { return }
        view.applyFont(self)
    }
}
