//
//  Puyo+UITextField.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/3.
//

import Foundation

public extension Puyo where T: UITextField {
    /// Needs relayout while textfield editing
    @discardableResult
    func resizeByContent() -> Self {
        onControlEvent(.editingChanged, Inputs { [weak view] _ in
            view?.py_setNeedsLayoutIfMayBeWrap()
        })
    }

    @discardableResult
    func onText<S: Outputing & Inputing>(_ text: S) -> Self where S.OutputType: OptionalableValueType, S.OutputType.Wrap == String, S.InputType == S.OutputType {
        text.safeBind(to: view) { v, a in
            guard a.optionalValue != v.text else { return }
            v.text = a.optionalValue
            v.py_setNeedsLayoutIfMayBeWrap()
        }

        texting(text)

        return self
    }

    @discardableResult
    func texting<S: Inputing>(_ text: S) -> Self where S.InputType: OptionalableValueType, S.InputType.Wrap == String {
        onControlEvent(.editingChanged, text.asInput { $0.text as! S.InputType })
    }

    @discardableResult
    func placeholder<S: Outputing>(_ text: S) -> Self where S.OutputType: OptionalableValueType, S.OutputType.Wrap == String {
        set(\T.placeholder, text.asOutput().map(\.optionalValue))
    }
}
