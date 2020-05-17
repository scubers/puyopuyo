//
//  WeakCatcher.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/20.
//

import Foundation

public struct WeakCatcher<T: AnyObject> {
    public private(set) weak var value: T?
    public init(value: T?) {
        self.value = value
    }

    public func execute<Result>(_ action: (T) -> Result, fallback: Result) -> Result {
        if let value = value {
            return action(value)
        }
        return fallback
    }

    public func voidExecute(_ action: (T) -> Void) {
        execute(action, fallback: ())
    }
    
    public static func `catch`(_ object: T, block: (WeakCatcher<T>) -> Void) {
        block(WeakCatcher(value: object))
    }
}

public protocol WeakCatchable {
    associatedtype Object: AnyObject
    var catchedWeakObject: Object? { get }
}

extension WeakCatcher: WeakCatchable {
    public var catchedWeakObject: T? { value }
}
