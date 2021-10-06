//
//  Puyo+Styles.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/25.
//

import Foundation

public extension Puyo where T: TintColorDecorable & UIView {
    @discardableResult
    func tintColor<S: Outputing>(_ color: S, state: UIControl.State = .normal) -> Self where S.OutputType: OptionalableValueType, S.OutputType.Wrap == UIColor {
        doOn(color) { $0.applyTintColor($1.optionalValue, state: state) }
    }

    @discardableResult
    func tintColor(_ color: UIColor?, state: UIControl.State = .normal) -> Self {
        tintColor(State(color), state: state)
    }
}

public extension Puyo where T: ImageDecorable & UIView {
    @discardableResult
    func image<S: Outputing>(_ image: S, state: UIControl.State = .normal) -> Self where S.OutputType: OptionalableValueType, S.OutputType.Wrap == UIImage {
        doOn(image) { $0.applyImage($1.optionalValue, state: state) }
    }

    @discardableResult
    func renderingImage<S: Outputing>(_ image: S, mode: UIImage.RenderingMode = .alwaysTemplate, state: UIControl.State = .normal) -> Self where S.OutputType: OptionalableValueType, S.OutputType.Wrap == UIImage {
        doOn(image.asOutput().map { $0.optionalValue?.withRenderingMode(mode) }, { $0.applyImage($1, state: state) })
    }

    @discardableResult
    func templatedImage<S: Outputing>(_ image: S, state: UIControl.State = .normal) -> Self where S.OutputType: OptionalableValueType, S.OutputType.Wrap == UIImage {
        renderingImage(image, mode: .alwaysTemplate, state: state)
    }
}

public extension Puyo where T: TextAlignmentDecorable & UIView {
    @discardableResult
    func textAlignment<S: Outputing>(_ alignment: S) -> Self where S.OutputType == NSTextAlignment {
        doOn(alignment) { $0.applyTextAlignment($1, state: .normal) }
    }

    @discardableResult
    func textAlignment(_ alignment: NSTextAlignment) -> Self {
        textAlignment(alignment.asOutput())
    }
}

public extension Puyo where T: TextLinesDecorable & UIView {
    @discardableResult
    func numberOfLines<S: Outputing>(_ lines: S) -> Self where S.OutputType == Int {
        viewUpdate(on: lines, strategy: .maybeWrap) { $0.applyNumberOfLine($1) }
    }
}

public extension Puyo where T: FontDecorable & UIView {
    @discardableResult
    func font<S: Outputing>(_ font: S) -> Self where S.OutputType: OptionalableValueType, S.OutputType.Wrap == UIFont {
        viewUpdate(on: font, strategy: .maybeWrap) { $0.applyFont($1.optionalValue) }
    }

    @available(iOS 8.2, *)
    @discardableResult
    func fontSize<S: Outputing>(_ font: S, weight: UIFont.Weight = .regular) -> Self where S.OutputType: CGFloatable {
        viewUpdate(on: font, strategy: .maybeWrap) { $0.applyFont(.systemFont(ofSize: $1.cgFloatValue, weight: weight)) }
    }
}

public extension Puyo where T: TextColorDecorable & UIView {
    @discardableResult
    func textColor<S: Outputing>(_ color: S, state: UIControl.State = .normal) -> Self where S.OutputType: OptionalableValueType, S.OutputType.Wrap == UIColor {
        doOn(color) { $0.applyTextColor($1.optionalValue, state: state) }
    }
}

public extension Puyo where T: TextDecorable & UIView {
    @discardableResult
    func text<S: Outputing>(_ text: S, state: UIControl.State = .normal) -> Self where S.OutputType: OptionalableValueType, S.OutputType.Wrap == String {
        viewUpdate(on: text.mapWrappedValue().distinct(), strategy: .maybeWrap) { $0.applyText($1, state: state) }
    }

    @discardableResult
    func attrText<S: Outputing>(_ text: S, state: UIControl.State = .normal) -> Self where S.OutputType: OptionalableValueType, S.OutputType.Wrap == NSAttributedString {
        viewUpdate(on: text.mapWrappedValue().distinct(), strategy: .maybeWrap) { $0.applyAttrText($1, state: state) }
    }
}

public extension Puyo where T: BgImageDecorable & UIView {
    @discardableResult
    func backgroundImage<S: Outputing>(_ image: S, state: UIControl.State = .normal) -> Self where S.OutputType: OptionalableValueType, S.OutputType.Wrap == UIImage {
        doOn(image) { $0.applyBgImage($1.optionalValue, state: state) }
    }
}

public extension Puyo where T: KeyboardTypeDecorable & UIView {
    @discardableResult
    func keyboardType<S: Outputing>(_ type: S) -> Self where S.OutputType == UIKeyboardType {
        doOn(type) { $0.applyKeyboardType($1) }
    }

    @discardableResult
    func keyboardType(_ type: UIKeyboardType) -> Self {
        keyboardType(type.asOutput())
    }
}
