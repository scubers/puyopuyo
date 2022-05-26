//
//  Puyo+NSObject.swift
//  Puyopuyo
//
//  Created by J on 2021/9/7.
//

import Foundation

public extension Puyo where T: AutoDisposable {
    @available(*, deprecated, message: "use assign")
    @discardableResult
    func set<O: Outputing>(_ keyPath: ReferenceWritableKeyPath<T, O.OutputType>, _ output: O) -> Self {
        doOn(output) { $0[keyPath: keyPath] = $1 }
    }

    @available(*, deprecated, message: "use bind")
    @discardableResult
    func set<R>(_ keyPath: ReferenceWritableKeyPath<T, R>, _ value: R) -> Self {
        view[keyPath: keyPath] = value
        return self
    }
}

public extension Puyo {
    @discardableResult
    func assign<R>(_ keyPath: ReferenceWritableKeyPath<T, R>, _ value: R) -> Self {
        view[keyPath: keyPath] = value
        return self
    }

    @discardableResult
    func assign<R>(_ keyPath: ReferenceWritableKeyPath<T, R?>, _ value: R) -> Self {
        view[keyPath: keyPath] = value
        return self
    }
}

public extension Puyo where T: AutoDisposable {
    @discardableResult
    func bind<O: Outputing, R>(_ keyPath: ReferenceWritableKeyPath<T, R>, _ output: O) -> Self where O.OutputType == R {
        doOn(output) { $0[keyPath: keyPath] = $1 }
    }
    
    @discardableResult
    func bind<O: Outputing, R>(_ keyPath: ReferenceWritableKeyPath<T, R?>, _ output: O) -> Self where O.OutputType == R {
        doOn(output) { $0[keyPath: keyPath] = $1 }
    }

}


public extension Puyo where T: _KeyValueCodingAndObserving & AutoDisposable {
    @discardableResult
    func observe<I: Inputing, R>(_ keyPath: KeyPath<T, R>, input: I) -> Self where I.InputType == R? {
        view.py_observing(keyPath).send(to: input).dispose(by: view)
        return self
    }
}
