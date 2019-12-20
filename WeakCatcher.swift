//
//  WeakCatcher.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/20.
//

import Foundation

public struct WeakCatcher<T: AnyObject> {
    weak var value: T?
    public init(value: T?) {
        self.value = value
    }
    
    public func execute<Result>(_ action: (T) -> Result?) -> Result? {
        if let value = value {
            return action(value)
        }
        return nil
    }
}
