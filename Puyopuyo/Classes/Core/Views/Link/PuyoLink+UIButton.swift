//
//  PuyoLink+UIButton.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/1.
//

import Foundation

extension PuyoLink where T: UIButton {
    @discardableResult
    public func title<S: ValueOutputing>(_ title: S, state: UIControl.State) -> Self where S.OutputType == String? {
        view.py_setUnbinder(title.safeBind(view, { (v, a) in
            v.setTitle(a, for: state)
        }), for: "\(#function)_\(state)")
        return self
    }
    
    @discardableResult
    public func titleColor<S: ValueOutputing>(_ title: S, state: UIControl.State) -> Self where S.OutputType == UIColor? {
        view.py_setUnbinder(title.safeBind(view, { (v, a) in
            v.setTitleColor(a, for: state)
        }), for: "\(#function)_\(state)")
        return self
    }
    
    @discardableResult
    public func image<S: ValueOutputing>(_ title: S, state: UIControl.State) -> Self where S.OutputType == UIImage? {
        view.py_setUnbinder(title.safeBind(view, { (v, a) in
            v.setImage(a, for: state)
        }), for: "\(#function)_\(state)")
        return self
    }
    
}
