//
//  Puyo+NSObject.swift
//  Puyopuyo
//
//  Created by J on 2021/9/7.
//

import Foundation

public extension Puyo where T: NSObject {
    @discardableResult
    func observe<I: Inputing, R>(_ keyPath: KeyPath<T, R>, input: I) -> Self where I.InputType == R? {
        view.py_observing(keyPath).send(to: input).dispose(by: view)
        return self
    }
}
