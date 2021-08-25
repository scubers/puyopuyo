//
//  Puyo+UIImage.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/1.
//

import Foundation

public extension Puyo where T: UIImageView {
    @discardableResult
    func hightligitedImage<S: Outputing>(_ image: S) -> Self where S.OutputType: OptionalableValueType, S.OutputType.Wrap == UIImage {
        keyPath(\T.image, image.asOutput().map(\.optionalValue))
//        view.addDisposer(image.catchObject(view, { v, a in
//            v.image = a.optionalValue
//        }), for: #function)
//        return self
    }
}
