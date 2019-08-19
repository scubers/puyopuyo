//
//  PuyoLink+UIImage.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/1.
//

import Foundation

extension PuyoLink where T: UIImageView {
    @discardableResult
    public func image<S: Valuable>(_ image: S) -> Self where S.ValueType == UIImage? {
        view.py_setUnbinder(image.safeBind(view, { (v, a) in
            v.image = a
        }), for: #function)
        return self
    }
}
