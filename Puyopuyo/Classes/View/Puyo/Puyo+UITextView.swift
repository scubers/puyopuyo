//
//  Puyo+UITextView.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/10.
//

import Foundation

extension Puyo where T: UITextView {
    
    @discardableResult
    public func onText<S: Outputing & Inputing>(_ text: S) -> Self where S.OutputType == String?, S.InputType == String? {
        view.py_setUnbinder(text.safeBind(view, { (v, a) in
            guard a != v.text else { return }
            v.text = a
            v.py_setNeedsLayoutIfMayBeWrap()
        }), for: "\(#function)_output")
        
        let output = SimpleOutput<String?> { (input) -> Unbinder in
            let obj = NotificationCenter.default.addObserver(forName: UITextView.textDidChangeNotification, object: self.view, queue: OperationQueue.main) { (noti) in
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
        let unbinder = output.distinct().send(to: text)
        view.py_setUnbinder(unbinder, for: "\(#function)_input")
        return self
    }
}
