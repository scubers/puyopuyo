//
//  WeakableObject.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/20.
//

import Foundation

///
/// Create a weak reference
public struct WeakableObject<T: AnyObject> {
    public private(set) weak var value: T?
    public init(value: T?) {
        self.value = value
    }
}

public extension WeakableObject {
    func `do`<Result>(_ action: (T) -> Result, fallback: Result) -> Result {
        if let value = value {
            return action(value)
        }
        return fallback
    }

    func voidExecute(_ action: (T) -> Void) {
        self.do(action, fallback: ())
    }
}
