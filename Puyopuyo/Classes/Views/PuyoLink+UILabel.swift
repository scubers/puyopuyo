//
//  PuyoLink+UILabel.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/1.
//

import Foundation

extension PuyoLink where T: UILabel {
    @discardableResult
    public func text<S: Stateful>(_ text: S) -> Self where S.StateType == Optional<String> {
        view.py_setUnbinder(text.safeBind(view, { (v, a) in
            v.text = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func textColor<S: Stateful>(_ color: S) -> Self where S.StateType == UIColor {
        view.py_setUnbinder(color.safeBind(view, { (v, a) in
            v.textColor = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func font<S: Stateful>(_ font: S) -> Self where S.StateType == UIFont {
        view.py_setUnbinder(font.safeBind(view, { (v, a) in
            v.font = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func textAligment<S: Stateful>(_ aligment: S) -> Self where S.StateType == NSTextAlignment {
        view.py_setUnbinder(aligment.safeBind(view, { (v, a) in
            v.textAlignment = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func numberOfLines<S: Stateful>(_ lines: S) -> Self where S.StateType == Int {
        view.py_setUnbinder(lines.safeBind(view, { (v, a) in
            v.numberOfLines = a
        }), for: #function)
        return self
    }
    
}
