//
//  PuyoLink+ListBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/2.
//

import Foundation

extension PuyoLink where T: ListBox<BoxView, Any> {
    @discardableResult
    public func cellData() -> Self {
//        view.py_setUnbinder(image.safeBind(view, { (v, a) in
//            v.image = a
//        }), for: #function)
        return self
    }

}
