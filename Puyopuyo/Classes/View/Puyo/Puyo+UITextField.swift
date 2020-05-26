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
        view.py_setUnbinder(delegate.catchObject(view, { v, s in
            v.delegate = s
        }), for: #function)
        return self
    }

    /// 若TextField可能包裹，则每次输入都会重新布局，若非必要，不要设置
    @discardableResult
    func resizeByContent() -> Self {
        bind(to: view, event: .editingChanged) { (v, _) in
            v.py_setNeedsLayoutIfMayBeWrap()
        }
        return self
    }

    @discardableResult
    func onText<S: Outputing & Inputing>(_ text: S) -> Self where S.OutputType: PuyoOptionalType, S.OutputType.PuyoWrappedType == String, S.InputType == S.OutputType {
        view.py_setUnbinder(text.catchObject(view, { v, a in
            guard a.puyoWrapValue != v.text else { return }
            v.text = a.puyoWrapValue
            v.py_setNeedsLayoutIfMayBeWrap()
        }), for: #function)

        bind(to: view, event: .editingChanged) { (_, v) in
            text.input(value: _getOptionalType(from: v.text))
        }
        return self
    }

    @discardableResult
    func texting<S: Inputing>(_ text: S) -> Self where S.InputType: PuyoOptionalType, S.InputType.PuyoWrappedType == String {
        bind(to: view, event: .editingChanged) { (_, v) in
            text.input(value: _getOptionalType(from: v.text))
        }
        return self
    }

    @discardableResult
    func placeholder<S: Outputing>(_ text: S) -> Self where S.OutputType: PuyoOptionalType, S.OutputType.PuyoWrappedType == String {
        view.py_setUnbinder(text.catchObject(view, { v, a in
            v.placeholder = a.puyoWrapValue
        }), for: #function)
        return self
    }

    @discardableResult
    func clearButtonMode(_ mode: UITextField.ViewMode) -> Self {
        view.clearButtonMode = mode
        return self
    }
}
