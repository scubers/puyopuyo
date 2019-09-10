//
//  Puyo+UIButton.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/1.
//

import Foundation

extension Puyo where T: UIButton {
    @discardableResult
    public func title<S: Outputing>(_ title: S, state: UIControl.State) -> Self where S.OutputType == String? {
        view.py_setUnbinder(title.yo.safeBind(view, { (v, a) in
            v.setTitle(a, for: state)
        }), for: "\(#function)_\(state)")
        return self
    }
    
    @discardableResult
    public func titleColor<S: Outputing>(_ title: S, state: UIControl.State) -> Self where S.OutputType == UIColor? {
        view.py_setUnbinder(title.yo.safeBind(view, { (v, a) in
            v.setTitleColor(a, for: state)
        }), for: "\(#function)_\(state)")
        return self
    }
    
    @discardableResult
    public func image<S: Outputing>(_ title: S, state: UIControl.State) -> Self where S.OutputType == UIImage? {
        view.py_setUnbinder(title.yo.safeBind(view, { (v, a) in
            v.setImage(a, for: state)
        }), for: "\(#function)_\(state)")
        return self
    }
    
}
