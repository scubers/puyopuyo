//
//  Puyo+UITextView.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/10.
//

import Foundation

public extension Puyo where T: UITextView {
    @discardableResult
    func onText<S: Outputing & Inputing>(_ text: S) -> Self where S.OutputType: OptionalableValueType, S.InputType == S.OutputType, S.OutputType.Wrap == String {
        view.addDisposable(text.catchObject(view) { v, a in
            guard a.optionalValue != v.text else { return }
            v.text = a.optionalValue
            v.py_setNeedsLayoutIfMayBeWrap()
        }, for: "\(#function)_output")

        let output = SimpleOutput<String?> { input -> Disposable in
            let obj = NotificationCenter.default.addObserver(forName: UITextView.textDidChangeNotification, object: self.view, queue: OperationQueue.main) { noti in
                if let tv = noti.object as? UITextView {
                    input.input(value: tv.text)
                    tv.py_setNeedsLayoutIfMayBeWrap()
                } else {
                    input.input(value: nil)
                }
            }
            return Disposables.create {
                NotificationCenter.default.removeObserver(obj)
            }
        }
        let Disposable = output.distinct().map { $0 as! S.InputType }.send(to: text)
        view.addDisposable(Disposable, for: "\(#function)_input")
        return self
    }

    @discardableResult
    func textChange<S: Inputing>(_ text: S) -> Self where S.InputType == String? {
        let output = SimpleOutput<String?> { input -> Disposable in
            let obj = NotificationCenter.default.addObserver(forName: UITextView.textDidChangeNotification, object: self.view, queue: OperationQueue.main) { noti in
                if let tv = noti.object as? UITextView {
                    input.input(value: tv.text)
                    tv.py_setNeedsLayoutIfMayBeWrap()
                } else {
                    input.input(value: nil)
                }
            }
            return Disposables.create {
                NotificationCenter.default.removeObserver(obj)
            }
        }
        let Disposable = output.distinct().send(to: text)
        view.addDisposable(Disposable, for: "\(#function)")
        return self
    }

    func onEndEditing<I: Inputing>(_ input: I) -> Self where I.InputType == String? {
        let output = SimpleOutput<String?> { input -> Disposable in
            let obj = NotificationCenter.default.addObserver(forName: UITextView.textDidEndEditingNotification, object: self.view, queue: OperationQueue.main) { noti in
                if let tv = noti.object as? UITextView {
                    input.input(value: tv.text)
                    tv.py_setNeedsLayoutIfMayBeWrap()
                } else {
                    input.input(value: nil)
                }
            }
            return Disposables.create {
                NotificationCenter.default.removeObserver(obj)
            }
        }
        let Disposable = output.distinct().send(to: input)
        view.addDisposable(Disposable, for: "\(#function)")
        return self
    }
}
