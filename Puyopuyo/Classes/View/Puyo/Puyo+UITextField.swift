//
//  Puyo+UITextField.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/3.
//

import Foundation

public extension Puyo where T: UITextField {
    @discardableResult
    func textDelegate<S: Outputing>(_ delegate: S) -> Self where S.OutputType == UITextFieldDelegate? {
        bind(keyPath: \T.delegate, delegate.asOutput().map(\.optionalValue))
    }

    /// 若TextField可能包裹，则每次输入都会重新布局，若非必要，不要设置
    @discardableResult
    func resizeByContent() -> Self {
        bind(to: view, event: .editingChanged) { v, _ in
            v.py_setNeedsLayoutIfMayBeWrap()
        }
        return self
    }

    @discardableResult
    func onText<S: Outputing & Inputing>(_ text: S) -> Self where S.OutputType: OptionalableValueType, S.OutputType.Wrap == String, S.InputType == S.OutputType {
        text.safeBind(to: view) { v, a in
            guard a.optionalValue != v.text else { return }
            v.text = a.optionalValue
            v.py_setNeedsLayoutIfMayBeWrap()
        }

        bind(to: view, event: .editingChanged) { _, v in
            text.input(value: v.text as! S.InputType)
        }
        return self
    }

    @discardableResult
    func texting<S: Inputing>(_ text: S) -> Self where S.InputType: OptionalableValueType, S.InputType.Wrap == String {
        bind(to: view, event: .editingChanged) { _, v in
            text.input(value: v.text as! S.InputType)
        }
        return self
    }

    @discardableResult
    func placeholder<S: Outputing>(_ text: S) -> Self where S.OutputType: OptionalableValueType, S.OutputType.Wrap == String {
        bind(keyPath: \T.placeholder, text.asOutput().map(\.optionalValue))
    }

    @discardableResult
    func clearButtonMode(_ mode: UITextField.ViewMode) -> Self {
        bind(keyPath: \T.clearButtonMode, State(mode))
    }
}
