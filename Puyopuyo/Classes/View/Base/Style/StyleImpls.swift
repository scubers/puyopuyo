//
//  StyleImpls.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/30.
//

import Foundation

// MARK: - UILabel

extension UILabel: TextColorDecorable,
    TextAlignmentDecorable,
    TextLinesDecorable,
    FontDecorable,
    TintColorDecorable,
    TextDecorable {
    public func applyTintColor(_ color: UIColor?, state _: UIControl.State) {
        tintColor = color
    }

    public func applyText(_ text: String?, state _: UIControl.State) {
        self.text = text
    }

    public func applyAttrText(_ text: NSAttributedString?, state _: UIControl.State) {
        attributedText = text
    }

    public func applyFont(_ font: UIFont?) {
        self.font = font
    }

    public func applyTextColor(_ color: UIColor?, state _: UIControl.State) {
        textColor = color
    }

    public func applyTextAlignment(_ alignment: NSTextAlignment, state _: UIControl.State) {
        textAlignment = alignment
    }

    public func applyNumberOfLine(_ line: Int) {
        numberOfLines = line
    }
}

// MARK: - UITextField

extension UITextField: TextColorDecorable,
    TextAlignmentDecorable,
    TextLinesDecorable,
    FontDecorable,
    TextDecorable,
    TintColorDecorable,
    KeyboardTypeDecorable,
    BgImageDecorable {
    public func applyKeyboardType(_ type: UIKeyboardType) {
        keyboardType = type
    }

    public func applyTintColor(_ color: UIColor?, state _: UIControl.State) {
        tintColor = color
    }

    public func applyBgImage(_ image: UIImage?, state: UIControl.State) {
        if state == .disabled {
            disabledBackground = image
        } else {
            background = image
        }
    }

    public func applyText(_ text: String?, state _: UIControl.State) {
        self.text = text
    }

    public func applyAttrText(_ text: NSAttributedString?, state _: UIControl.State) {
        attributedText = text
    }

    public func applyFont(_ font: UIFont?) {
        self.font = font
    }

    public func applyTextColor(_ color: UIColor?, state _: UIControl.State) {
        textColor = color
    }

    public func applyTextAlignment(_ alignment: NSTextAlignment, state _: UIControl.State) {
        textAlignment = alignment
    }

    public func applyNumberOfLine(_: Int) {}
}

// MARK: - UITextView

extension UITextView: TextColorDecorable,
    TextAlignmentDecorable,
    TextLinesDecorable,
    FontDecorable,
    KeyboardTypeDecorable,
    TextDecorable {
    public func applyKeyboardType(_ type: UIKeyboardType) {
        keyboardType = type
    }

    public func applyText(_ text: String?, state _: UIControl.State) {
        self.text = text
    }

    public func applyAttrText(_ text: NSAttributedString?, state _: UIControl.State) {
        attributedText = text
    }

    public func applyFont(_ font: UIFont?) {
        self.font = font
    }

    public func applyTextColor(_ color: UIColor?, state _: UIControl.State) {
        textColor = color
    }

    public func applyTextAlignment(_ alignment: NSTextAlignment, state _: UIControl.State) {
        textAlignment = alignment
    }

    public func applyNumberOfLine(_: Int) {}
}

// MARK: - UIButton

extension UIButton: TextColorDecorable,
    TextAlignmentDecorable,
    TextLinesDecorable,
    ImageDecorable,
    BgImageDecorable,
    TitleShadowColorDecorable,
    FontDecorable,
    TextDecorable,
    TintColorDecorable {
    public func applyTintColor(_ color: UIColor?, state _: UIControl.State) {
        tintColor = color
    }

    public func applyText(_ text: String?, state: UIControl.State) {
        setTitle(text, for: state)
    }

    public func applyAttrText(_ text: NSAttributedString?, state: UIControl.State) {
        setAttributedTitle(text, for: state)
    }

    public func applyFont(_ font: UIFont?) {
        titleLabel?.font = font
    }

    public func applyTextColor(_ color: UIColor?, state: UIControl.State) {
        setTitleColor(color, for: state)
    }

    public func applyTextAlignment(_ alignment: NSTextAlignment, state _: UIControl.State) {
        titleLabel?.textAlignment = alignment
    }

    public func applyNumberOfLine(_ line: Int) {
        titleLabel?.numberOfLines = line
    }

    public func applyImage(_ image: UIImage?, state: UIControl.State) {
        setImage(image, for: state)
    }

    public func applyBgImage(_ image: UIImage?, state: UIControl.State) {
        setBackgroundImage(image, for: state)
    }

    public func applyTitleShadowColor(_ color: UIColor?, state: UIControl.State) {
        setTitleShadowColor(color, for: state)
    }
}

// MARK: - UIImageView

extension UIImageView: ImageDecorable,
    TintColorDecorable,
    BgImageDecorable {
    public func applyBgImage(_ image: UIImage?, state _: UIControl.State) {
        self.image = image
    }

    public func applyImage(_ image: UIImage?, state _: UIControl.State) {
        self.image = image
    }

    public func applyTintColor(_ color: UIColor?, state _: UIControl.State) {
        tintColor = color
    }
}

// MARK: - UIBarButtonItem

extension UIBarButtonItem: TintColorDecorable {
    public func applyTintColor(_ color: UIColor?, state _: UIControl.State) {
        tintColor = color
    }
}

// MARK: - UINavigationBar

extension UINavigationBar: TintColorDecorable {
    public func applyTintColor(_ color: UIColor?, state _: UIControl.State) {
        tintColor = color
    }
}

extension UISearchBar: KeyboardTypeDecorable,
    TintColorDecorable {
    public func applyTintColor(_ color: UIColor?, state _: UIControl.State) {
        tintColor = color
    }

    public func applyKeyboardType(_ type: UIKeyboardType) {
        keyboardType = type
    }
}

extension UISlider: TintColorDecorable {
    public func applyTintColor(_ color: UIColor?, state _: UIControl.State) {
        tintColor = color
    }
}

extension UISwitch: TintColorDecorable {
    public func applyTintColor(_ color: UIColor?, state _: UIControl.State) {
        tintColor = color
    }
}

extension BoxView: PaddingDecorable {
    public func applyPadding(_ padding: UIEdgeInsets) {
        regulator.padding = padding
    }
}
