//
//  Puyo+UIImage.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/1.
//

import Foundation

public extension Puyo where T: UIImageView {

    @discardableResult
    func hightligitedImage<S: Outputing>(_ image: S) -> Self where S.OutputType: PuyoOptionalType, S.OutputType.PuyoWrappedType == UIImage {
        view.py_setUnbinder(image.catchObject(view, { v, a in
            v.image = a.puyoWrapValue
        }), for: #function)
        return self
    }
}
