//
//  Puyo+Styles.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/25.
//

import Foundation

public extension Puyo where T: TintColorDecorable {
    @discardableResult
    func tintColor<S: Outputing>(_ color: S, state: UIControl.State = .normal) -> Self where S.OutputType: PuyoOptionalType, S.OutputType.PuyoWrappedType == UIColor {
        view.py_setUnbinder(color.safeBind(view, { v, a in
            v.applyTintColor(a.puyoWrapValue, state: state)
        }), for: "\(#function)_\(state)")
        return self
    }

    @discardableResult
    func tintColor(_ color: UIColor?, state: UIControl.State = .normal) -> Self {
        view.applyTintColor(color, state: state)
        return self
    }
}

public extension Puyo where T: ImageDecorable {
    @discardableResult
    func image<S: Outputing>(_ image: S, state: UIControl.State = .normal) -> Self where S.OutputType: PuyoOptionalType, S.OutputType.PuyoWrappedType == UIImage {
        view.py_setUnbinder(image.safeBind(view, { v, a in
            v.applyImage(a.puyoWrapValue, state: state)
        }), for: #function + "\(state)")
        return self
    }
}

public extension Puyo where T: TextAlignmentDecorable {
    @discardableResult
    func textAlignment<S: Outputing>(_ alignment: S) -> Self where S.OutputType == NSTextAlignment {
        view.py_setUnbinder(alignment.safeBind(view, { v, a in
            v.applyTextAlignment(a, state: .normal)
        }), for: #function)
        return self
    }

    @discardableResult
    func textAlignment(_ alignment: NSTextAlignment) -> Self {
        view.applyTextAlignment(alignment, state: .normal)
        return self
    }
}

public extension Puyo where T: TextLinesDecorable {
    @discardableResult
    func numberOfLines<S: Outputing>(_ lines: S) -> Self where S.OutputType == Int {
        view.py_setUnbinder(lines.safeBind(view, { v, a in
            v.applyNumberOfLine(a)
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
}

public extension Puyo where T: FontDecorable {
    @discardableResult
    func font<S: Outputing>(_ font: S) -> Self where S.OutputType: PuyoOptionalType, S.OutputType.PuyoWrappedType == UIFont {
        view.py_setUnbinder(font.safeBind(view, { v, a in
            v.applyFont(a.puyoWrapValue)
            v.py_setNeedsLayoutIfMayBeWrap()
        }), for: #function)
        return self
    }

    @available(iOS 8.2, *)
    @discardableResult
    func fontSize<S: Outputing>(_ font: S, weight: UIFont.Weight = .regular) -> Self where S.OutputType: CGFloatable {
        view.py_setUnbinder(font.safeBind(view, { v, a in
            v.applyFont(UIFont.systemFont(ofSize: a.cgFloatValue, weight: weight))
            v.py_setNeedsLayoutIfMayBeWrap()
        }), for: #function)
        return self
    }
}

public extension Puyo where T: TextColorDecorable {
    @discardableResult
    func textColor<S: Outputing>(_ color: S, state: UIControl.State = .normal) -> Self where S.OutputType: PuyoOptionalType, S.OutputType.PuyoWrappedType == UIColor {
        view.py_setUnbinder(color.safeBind(view, { v, a in
            v.applyTextColor(a.puyoWrapValue, state: state)
        }), for: #function + "\(state)")
        return self
    }
}

public extension Puyo where T: TextDecorable {
    @discardableResult
    func text<S: Outputing>(_ text: S, state: UIControl.State = .normal) -> Self where S.OutputType: PuyoOptionalType, S.OutputType.PuyoWrappedType == String {
        view.py_setUnbinder(text.safeBind(view, { v, a in
            v.applyText(a.puyoWrapValue, state: state)
            v.py_setNeedsLayoutIfMayBeWrap()
        }), for: #function + "\(state)")
        return self
    }

    @discardableResult
    func attrText<S: Outputing>(_ text: S, state: UIControl.State = .normal) -> Self where S.OutputType: PuyoOptionalType, S.OutputType.PuyoWrappedType == NSAttributedString {
        view.py_setUnbinder(text.safeBind(view, { v, a in
            v.applyAttrText(a.puyoWrapValue, state: state)
            v.py_setNeedsLayoutIfMayBeWrap()
        }), for: #function + "\(state)")
        return self
    }
}

public extension Puyo where T: BgImageDecorable {
    @discardableResult
    func backgroundImage<S: Outputing>(_ image: S, state: UIControl.State = .normal) -> Self where S.OutputType: PuyoOptionalType, S.OutputType.PuyoWrappedType == UIImage {
        view.py_setUnbinder(image.safeBind(view, { v, a in
            v.applyBgImage(a.puyoWrapValue, state: state)
        }), for: "\(#function)_\(state)")
        return self
    }
}
