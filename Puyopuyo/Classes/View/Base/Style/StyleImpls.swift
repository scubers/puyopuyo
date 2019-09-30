//
//  StyleImpls.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/30.
//

import Foundation

// MARK: - UILabel
extension UILabel: TextColorStyleable, TextAligmentStyleable, TextLinesStyleable, FontStyleable {
    public func applyFont(_ font: UIFont?) {
        self.font = font
    }
    public func applyTextColor(_ color: UIColor?, state: UIControl.State) {
        textColor = color
    }
    public func applyTextAligment(_ aligment: NSTextAlignment, state: UIControl.State) {
        textAlignment = aligment
    }
    public func applyNumberOfLine(_ line: Int) {
        numberOfLines = line
    }
}
// MARK: - UITextField
extension UITextField: TextColorStyleable, TextAligmentStyleable, TextLinesStyleable, FontStyleable {
    public func applyFont(_ font: UIFont?) {
        self.font = font
    }
    public func applyTextColor(_ color: UIColor?, state: UIControl.State) {
        textColor = color
    }
    public func applyTextAligment(_ aligment: NSTextAlignment, state: UIControl.State) {
        textAlignment = aligment
    }
    public func applyNumberOfLine(_ line: Int) {
    }
}
// MARK: - UITextView
extension UITextView: TextColorStyleable, TextAligmentStyleable, TextLinesStyleable, FontStyleable {
    public func applyFont(_ font: UIFont?) {
        self.font = font
    }
    public func applyTextColor(_ color: UIColor?, state: UIControl.State) {
        textColor = color
    }
    public func applyTextAligment(_ aligment: NSTextAlignment, state: UIControl.State) {
        textAlignment = aligment
    }
    public func applyNumberOfLine(_ line: Int) {
    }
}
// MARK: - UIButton
extension UIButton: TextColorStyleable, TextAligmentStyleable, TextLinesStyleable, ImageStyleable, BgImageStyleable, TitleShadowColorStyleable, FontStyleable {
    public func applyFont(_ font: UIFont?) {
        titleLabel?.font = font
    }
    public func applyTextColor(_ color: UIColor?, state: UIControl.State) {
        setTitleColor(color, for: state)
    }
    public func applyTextAligment(_ aligment: NSTextAlignment, state: UIControl.State) {
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
extension UIImageView: ImageStyleable, TintColorStyleable {
    public func applyImage(_ image: UIImage?, state: UIControl.State) {
        self.image = image
    }
    public func applyTintColor(_ color: UIColor?, state: UIControl.State) {
        tintColor = color
    }
}
// MARK: - UIBarButtonItem
extension UIBarButtonItem: TintColorStyleable {
    public func applyTintColor(_ color: UIColor?, state: UIControl.State) {
        tintColor = color
    }
}
// MARK: - UINavigationBar
extension UINavigationBar: TintColorStyleable {
    public func applyTintColor(_ color: UIColor?, state: UIControl.State) {
        tintColor = color
    }
}
