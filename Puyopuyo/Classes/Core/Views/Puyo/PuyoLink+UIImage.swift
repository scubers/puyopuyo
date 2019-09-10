//
//  Puyo+UIImage.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/1.
//

import Foundation

extension Puyo where T: UIImageView {
    @discardableResult
    public func image<S: Outputing>(_ image: S) -> Self where S.OutputType == UIImage? {
        view.py_setUnbinder(image.yo.safeBind(view, { (v, a) in
            v.image = a
        }), for: #function)
        return self
    }
}
