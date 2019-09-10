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
        view.py_setUnbinder(text.yo.safeBind(view, { (v, a) in
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
        let unbinder = output.yo.distinct().yo.send(to: text)
        view.py_setUnbinder(unbinder, for: "\(#function)_input")
        return self
    }
    
    @discardableResult
    public func textColor<S: Outputing>(_ color: S) -> Self where S.OutputType == UIColor? {
        view.py_setUnbinder(color.yo.safeBind(view, { (v, a) in
            v.textColor = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func font<S: Outputing>(_ font: S) -> Self where S.OutputType == UIFont {
        view.py_setUnbinder(font.yo.safeBind(view, { (v, a) in
            v.font = a
            v.py_setNeedsLayoutIfMayBeWrap()
        }), for: #function)
        return self
    }
}
