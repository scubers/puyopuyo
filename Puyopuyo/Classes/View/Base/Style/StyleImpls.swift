//
//  StyleImpls.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/30.
//

import Foundation

// MARK: - UILabel

extension UILabel: TextColorDecorable, TextAligmentDecorable, TextLinesDecorable, FontDecorable {
    public func applyFont(_ font: UIFont?) {
        self.font = font
    }

    public func applyTextColor(_ color: UIColor?, state: UIControl.State) {
        guard state == .normal else { return }
        textColor = color
    }

    public func applyTextAligment(_ aligment: NSTextAlignment, state: UIControl.State) {
        guard state == .normal else { return }
        textAlignment = aligment
    }

    public func applyNumberOfLine(_ line: Int) {
        numberOfLines = line
    }
}

// MARK: - UITextField

extension UITextField: TextColorDecorable, TextAligmentDecorable, TextLinesDecorable, FontDecorable {
    public func applyFont(_ font: UIFont?) {
        self.font = font
    }

    public func applyTextColor(_ color: UIColor?, state: UIControl.State) {
        guard state == .normal else { return }
        textColor = color
    }

    public func applyTextAligment(_ aligment: NSTextAlignment, state: UIControl.State) {
        guard state == .normal else { return }
        textAlignment = aligment
    }

    public func applyNumberOfLine(_: Int) {}
}

// MARK: - UITextView

extension UITextView: TextColorDecorable, TextAligmentDecorable, TextLinesDecorable, FontDecorable {
    public func applyFont(_ font: UIFont?) {
        self.font = font
    }

    public func applyTextColor(_ color: UIColor?, state: UIControl.State) {
        guard state == .normal else { return }
        textColor = color
    }

    public func applyTextAligment(_ aligment: NSTextAlignment, state: UIControl.State) {
        guard state == .normal else { return }
        textAlignment = aligment
    }

    public func applyNumberOfLine(_: Int) {}
}

// MARK: - UIButton

extension UIButton: TextColorDecorable, TextAligmentDecorable, TextLinesDecorable, ImageDecorable, BgImageDecorable, TitleShadowColorDecorable, FontDecorable {
    public func applyFont(_ font: UIFont?) {
        titleLabel?.font = font
    }

    public func applyTextColor(_ color: UIColor?, state: UIControl.State) {
        setTitleColor(color, for: state)
    }

    public func applyTextAligment(_ aligment: NSTextAlignment, state _: UIControl.State) {
        titleLabel?.textAlignment = aligment
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

extension UIImageView: ImageDecorable, TintColorDecorable {
    public func applyImage(_ image: UIImage?, state: UIControl.State) {
        guard state == .normal else { return }
        self.image = image
    }

    public func applyTintColor(_ color: UIColor?, state: UIControl.State) {
        guard state == .normal else { return }
        tintColor = color
    }
}

// MARK: - UIBarButtonItem

extension UIBarButtonItem: TintColorDecorable {
    public func applyTintColor(_ color: UIColor?, state: UIControl.State) {
        guard state == .normal else { return }
        tintColor = color
    }
}

// MARK: - UINavigationBar

extension UINavigationBar: TintColorDecorable {
    public func applyTintColor(_ color: UIColor?, state: UIControl.State) {
        guard state == .normal else { return }
        tintColor = color
    }
}
