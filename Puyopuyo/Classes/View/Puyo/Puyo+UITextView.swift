//
//  Puyo+UITextView.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/10.
//

import Foundation

public extension Puyo where T: UITextView {
    @discardableResult
    func onText<S: Outputing & Inputing>(_ text: S) -> Self where S.OutputType: PuyoOptionalType, S.InputType == S.OutputType, S.OutputType.PuyoWrappedType == String {
        view.py_setUnbinder(text.catchObject(view) { v, a in
            guard a.puyoWrapValue != v.text else { return }
            v.text = a.puyoWrapValue
            v.py_setNeedsLayoutIfMayBeWrap()
        }, for: "\(#function)_output")

        let output = SimpleOutput<String?> { (input) -> Unbinder in
            let obj = NotificationCenter.default.addObserver(forName: UITextView.textDidChangeNotification, object: self.view, queue: OperationQueue.main) { noti in
                if let tv = noti.object as? UITextView {
                    input.input(value: tv.text)
                    tv.py_setNeedsLayoutIfMayBeWrap()
                } else {
                    input.input(value: nil)
                }
            }
            return Unbinders.create {
                NotificationCenter.default.removeObserver(obj)
            }
        }
        let unbinder = output.distinct().map { _getOptionalType(from: $0) }.send(to: text)
        view.py_setUnbinder(unbinder, for: "\(#function)_input")
        return self
    }

    @discardableResult
    func textChange<S: Inputing>(_ text: S) -> Self where S.InputType == String? {
        let output = SimpleOutput<String?> { (input) -> Unbinder in
            let obj = NotificationCenter.default.addObserver(forName: UITextView.textDidChangeNotification, object: self.view, queue: OperationQueue.main) { noti in
                if let tv = noti.object as? UITextView {
                    input.input(value: tv.text)
                    tv.py_setNeedsLayoutIfMayBeWrap()
                } else {
                    input.input(value: nil)
                }
            }
            return Unbinders.create {
                NotificationCenter.default.removeObserver(obj)
            }
        }
        let unbinder = output.distinct().map { _getOptionalType(from: $0) }.send(to: text)
        view.py_setUnbinder(unbinder, for: "\(#function)")
        return self
    }

    func onEndEditing<I: Inputing>(_ input: I) -> Self where I.InputType == String? {
        let output = SimpleOutput<String?> { (input) -> Unbinder in
            let obj = NotificationCenter.default.addObserver(forName: UITextView.textDidEndEditingNotification, object: self.view, queue: OperationQueue.main) { noti in
                if let tv = noti.object as? UITextView {
                    input.input(value: tv.text)
                    tv.py_setNeedsLayoutIfMayBeWrap()
                } else {
                    input.input(value: nil)
                }
            }
            return Unbinders.create {
                NotificationCenter.default.removeObserver(obj)
            }
        }
        let unbinder = output.distinct().map { _getOptionalType(from: $0) }.send(to: input)
        view.py_setUnbinder(unbinder, for: "\(#function)")
        return self
    }
}
