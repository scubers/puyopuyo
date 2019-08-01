//
//  PuyoLink+UILabel.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/1.
//

import Foundation

extension PuyoLink where T: UILabel {
    @discardableResult
    public func text(_ text: String?) -> Self  {
        view.text = text
        return self
    }
    
    @discardableResult
    public func text<S: Valuable>(_ text: S) -> Self where S.ValueType == String? {
        view.py_setUnbinder(text.safeBind(view, { (v, a) in
            v.text = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func textColor<S: Valuable>(_ color: S) -> Self where S.ValueType == UIColor? {
        view.py_setUnbinder(color.safeBind(view, { (v, a) in
            v.textColor = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func font<S: Valuable>(_ font: S) -> Self where S.ValueType == UIFont {
        view.py_setUnbinder(font.safeBind(view, { (v, a) in
            v.font = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func font(_ font: UIFont) -> Self {
        view.font = font
        return self
    }
    
    @discardableResult
    public func textAligment<S: Valuable>(_ aligment: S) -> Self where S.ValueType == NSTextAlignment {
        view.py_setUnbinder(aligment.safeBind(view, { (v, a) in
            v.textAlignment = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func numberOfLines<S: Valuable>(_ lines: S) -> Self where S.ValueType == Int {
        view.py_setUnbinder(lines.safeBind(view, { (v, a) in
            v.numberOfLines = a
        }), for: #function)
        return self
    }
    
}
