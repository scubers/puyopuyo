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
        view.py_setNeedsLayout()
        return self
    }
    
    @discardableResult
    public func font(_ font: UIFont) -> Self {
        view.font = font
        view.py_setNeedsLayout()
        return self
    }
    
    @discardableResult
    public func text<S: ValueOutputing>(_ text: S) -> Self where S.OutputType == String? {
        view.py_setUnbinder(text.safeBind(view, { (v, a) in
            v.text = a
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func textColor<S: ValueOutputing>(_ color: S) -> Self where S.OutputType == UIColor? {
        view.py_setUnbinder(color.safeBind(view, { (v, a) in
            v.textColor = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func font<S: ValueOutputing>(_ font: S) -> Self where S.OutputType == UIFont {
        view.py_setUnbinder(font.safeBind(view, { (v, a) in
            v.font = a
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func textAligment<S: ValueOutputing>(_ aligment: S) -> Self where S.OutputType == NSTextAlignment {
        view.py_setUnbinder(aligment.safeBind(view, { (v, a) in
            v.textAlignment = a
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func numberOfLines<S: ValueOutputing>(_ lines: S) -> Self where S.OutputType == Int {
        view.py_setUnbinder(lines.safeBind(view, { (v, a) in
            v.numberOfLines = a
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
}
