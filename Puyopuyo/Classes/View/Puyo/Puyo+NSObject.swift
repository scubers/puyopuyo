//
//  Puyo+NSObject.swift
//  Puyopuyo
//
//  Created by J on 2021/9/7.
//

import Foundation

public extension Puyo where T: DisposableBag {
    @discardableResult
    func set<O: Outputing>(_ keyPath: ReferenceWritableKeyPath<T, O.OutputType>, _ output: O) -> Self {
        output.safeBind(to: view) {
            $0[keyPath: keyPath] = $1
        }
        return self
    }

    @discardableResult
    func set<R>(_ keyPath: ReferenceWritableKeyPath<T, R>, _ value: R) -> Self {
        view[keyPath: keyPath] = value
        return self
    }
}

public extension Puyo where T: _KeyValueCodingAndObserving & DisposableBag {
    @discardableResult
    func observe<I: Inputing, R>(_ keyPath: KeyPath<T, R>, input: I) -> Self where I.InputType == R? {
        view.py_observing(keyPath).send(to: input).dispose(by: view)
        return self
    }
}
