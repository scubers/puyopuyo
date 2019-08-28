//
//  Puyo+UILabel.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/1.
//

import Foundation

extension Puyo where T: UILabel {
    
    
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
    public func text<S: Outputing>(_ text: S) -> Self where S.OutputType == String? {
        view.py_setUnbinder(text.safeBind(view, { (v, a) in
            v.text = a
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func textColor<S: Outputing>(_ color: S) -> Self where S.OutputType == UIColor? {
        view.py_setUnbinder(color.safeBind(view, { (v, a) in
            v.textColor = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func font<S: Outputing>(_ font: S) -> Self where S.OutputType == UIFont {
        view.py_setUnbinder(font.safeBind(view, { (v, a) in
            v.font = a
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func textAligment<S: Outputing>(_ aligment: S) -> Self where S.OutputType == NSTextAlignment {
        view.py_setUnbinder(aligment.safeBind(view, { (v, a) in
            v.textAlignment = a
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func numberOfLines<S: Outputing>(_ lines: S) -> Self where S.OutputType == Int {
        view.py_setUnbinder(lines.safeBind(view, { (v, a) in
            v.numberOfLines = a
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
}
