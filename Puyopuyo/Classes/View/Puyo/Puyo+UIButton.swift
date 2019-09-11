//
//  Puyo+UIButton.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/1.
//

import Foundation

extension Puyo where T: UIButton {
    
    @discardableResult
    public func title<S: Outputing>(_ title: S, state: UIControl.State) -> Self where S.OutputType: PuyoOptionalType, S.OutputType.PuyoWrappedType == String {
        view.py_setUnbinder(title.safeBind(view, { (v, a) in
            v.setTitle(a.puyoWrapValue, for: state)
        }), for: "\(#function)_\(state)")
        return self
    }
    
    @discardableResult
    public func titleColor<S: Outputing>(_ color: S, state: UIControl.State) -> Self where S.OutputType: PuyoOptionalType, S.OutputType.PuyoWrappedType == UIColor {
        view.py_setUnbinder(color.safeBind(view, { (v, a) in
            v.setTitleColor(a.puyoWrapValue, for: state)
        }), for: "\(#function)_\(state)")
        return self
    }
    
    @discardableResult
    public func image<S: Outputing>(_ title: S, state: UIControl.State) -> Self where S.OutputType: PuyoOptionalType, S.OutputType.PuyoWrappedType == UIImage {
        view.py_setUnbinder(title.safeBind(view, { (v, a) in
            v.setImage(a.puyoWrapValue, for: state)
        }), for: "\(#function)_\(state)")
        return self
    }
    
    @discardableResult
    public func backgroundImage<S: Outputing>(_ image: S, state: UIControl.State) -> Self where S.OutputType: PuyoOptionalType, S.OutputType.PuyoWrappedType == UIImage {
        view.py_setUnbinder(image.safeBind(view, { (v, a) in
            v.setBackgroundImage(a.puyoWrapValue, for: state)
        }), for: "\(#function)_\(state)")
        return self
    }
    
    @discardableResult
    public func attrTitle<S: Outputing>(_ title: S, state: UIControl.State) -> Self where S.OutputType: PuyoOptionalType, S.OutputType.PuyoWrappedType == NSAttributedString {
        view.py_setUnbinder(title.safeBind(view, { (v, a) in
            v.setAttributedTitle(a.puyoWrapValue, for: state)
        }), for: "\(#function)_\(state)")
        return self
    }
    
}
