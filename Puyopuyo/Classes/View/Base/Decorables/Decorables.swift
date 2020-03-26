//
//  KeyboardTypeDecorable.swift
//  Pods-Puyopuyo_Example
//
//  Created by Jrwong on 2020/1/8.
//

import Foundation

@objc public protocol Decorable {}

public protocol TintColorDecorable {
    func applyTintColor(_ color: UIColor?, state: UIControl.State)
}

public protocol KeyboardTypeDecorable {
    func applyKeyboardType(_ type: UIKeyboardType)
}

public protocol TextDecorable {
    func applyText(_ text: String?, state: UIControl.State)
    func applyAttrText(_ text: NSAttributedString?, state: UIControl.State)
}

public protocol PlaceholderTextDecorable {
    func applyPlaceholder(_ text: String?, state: UIControl.State)
}

public protocol TextColorDecorable {
    func applyTextColor(_ color: UIColor?, state: UIControl.State)
}

public protocol TextAlignmentDecorable {
    func applyTextAlignment(_ alignment: NSTextAlignment, state: UIControl.State)
}

public protocol TextLinesDecorable {
    func applyNumberOfLine(_ line: Int)
}

public protocol TitleShadowColorDecorable {
    func applyTitleShadowColor(_ color: UIColor?, state: UIControl.State)
}

public protocol FontDecorable {
    func applyFont(_ font: UIFont?)
}

public protocol ImageDecorable {
    func applyImage(_ image: UIImage?, state: UIControl.State)
}

public protocol BgImageDecorable {
    func applyBgImage(_ image: UIImage?, state: UIControl.State)
}

public protocol PaddingDecorable {
    func applyPadding(_ padding: UIEdgeInsets)
}
