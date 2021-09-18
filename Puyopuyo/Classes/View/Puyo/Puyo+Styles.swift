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
        color.safeBind(to: view) { v, a in
            v.applyTintColor(a.optionalValue, state: state)
        }
        return self
    }

    @discardableResult
    func tintColor(_ color: UIColor?, state: UIControl.State = .normal) -> Self {
        tintColor(State(color), state: state)
    }
}

public extension Puyo where T: ImageDecorable & UIView {
    @discardableResult
    func image<S: Outputing>(_ image: S, state: UIControl.State = .normal) -> Self where S.OutputType: OptionalableValueType, S.OutputType.Wrap == UIImage {
        image.safeBind(to: view) { v, a in
            v.applyImage(a.optionalValue, state: state)
        }
        return self
    }

    @discardableResult
    func renderingImage<S: Outputing>(_ image: S, mode: UIImage.RenderingMode = .alwaysTemplate, state: UIControl.State = .normal) -> Self where S.OutputType: OptionalableValueType, S.OutputType.Wrap == UIImage {
        self.image(image.asOutput().map { $0.optionalValue?.withRenderingMode(mode) },
                   state: state)
    }

    @discardableResult
    func templatedImage<S: Outputing>(_ image: S, state: UIControl.State = .normal) -> Self where S.OutputType: OptionalableValueType, S.OutputType.Wrap == UIImage {
        renderingImage(image, mode: .alwaysTemplate, state: state)
    }
}

public extension Puyo where T: TextAlignmentDecorable & UIView {
    @discardableResult
    func textAlignment<S: Outputing>(_ alignment: S) -> Self where S.OutputType == NSTextAlignment {
        alignment.safeBind(to: view) { v, a in
            v.applyTextAlignment(a, state: .normal)
        }
        return self
    }

    @discardableResult
    func textAlignment(_ alignment: NSTextAlignment) -> Self {
        textAlignment(alignment.asOutput())
    }
}

public extension Puyo where T: TextLinesDecorable & UIView {
    @discardableResult
    func numberOfLines<S: Outputing>(_ lines: S) -> Self where S.OutputType == Int {
        lines.safeBind(to: view) { v, a in
            v.applyNumberOfLine(a)
            v.py_setNeedsRelayout()
        }
        return self
    }
}

public extension Puyo where T: FontDecorable & UIView {
    @discardableResult
    func font<S: Outputing>(_ font: S) -> Self where S.OutputType: OptionalableValueType, S.OutputType.Wrap == UIFont {
        font.safeBind(to: view) { v, a in
            v.applyFont(a.optionalValue)
            v.py_setNeedsLayoutIfMayBeWrap()
        }
        return self
    }

    @available(iOS 8.2, *)
    @discardableResult
    func fontSize<S: Outputing>(_ font: S, weight: UIFont.Weight = .regular) -> Self where S.OutputType: CGFloatable {
        font.safeBind(to: view) { v, a in
            v.applyFont(UIFont.systemFont(ofSize: a.cgFloatValue, weight: weight))
            v.py_setNeedsLayoutIfMayBeWrap()
        }
        return self
    }
}

public extension Puyo where T: TextColorDecorable & UIView {
    @discardableResult
    func textColor<S: Outputing>(_ color: S, state: UIControl.State = .normal) -> Self where S.OutputType: OptionalableValueType, S.OutputType.Wrap == UIColor {
        color.safeBind(to: view) { v, a in
            v.applyTextColor(a.optionalValue, state: state)
        }
        return self
    }
}

public extension Puyo where T: TextDecorable & UIView {
    @discardableResult
    func text<S: Outputing>(_ text: S, state: UIControl.State = .normal) -> Self where S.OutputType: OptionalableValueType, S.OutputType.Wrap == String {
        text.mapWrappedValue().distinct().safeBind(to: view) { v, a in
            v.applyText(a, state: state)
            v.py_setNeedsLayoutIfMayBeWrap()
        }
        return self
    }

    @discardableResult
    func attrText<S: Outputing>(_ text: S, state: UIControl.State = .normal) -> Self where S.OutputType: OptionalableValueType, S.OutputType.Wrap == NSAttributedString {
        text.mapWrappedValue().distinct().safeBind(to: view) { v, a in
            v.applyAttrText(a, state: state)
            v.py_setNeedsLayoutIfMayBeWrap()
        }
        return self
    }
}

public extension Puyo where T: BgImageDecorable & UIView {
    @discardableResult
    func backgroundImage<S: Outputing>(_ image: S, state: UIControl.State = .normal) -> Self where S.OutputType: OptionalableValueType, S.OutputType.Wrap == UIImage {
        image.safeBind(to: view) { v, a in
            v.applyBgImage(a.optionalValue, state: state)
        }
        return self
    }
}

public extension Puyo where T: KeyboardTypeDecorable & UIView {
    @discardableResult
    func keyboardType<S: Outputing>(_ type: S) -> Self where S.OutputType == UIKeyboardType {
        type.safeBind(to: view) { v, a in
            v.applyKeyboardType(a)
        }
        return self
    }

    @discardableResult
    func keyboardType(_ type: UIKeyboardType) -> Self {
        keyboardType(type.asOutput())
    }
}
