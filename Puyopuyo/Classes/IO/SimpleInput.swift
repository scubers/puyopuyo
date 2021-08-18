//
//  SimpleInput.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/8.
//

import Foundation

public struct SimpleInput<T>: Inputing {
    public typealias InputType = T
    public func input(value: SimpleInput<T>.InputType) {
        action(value)
    }

    private let action: (T) -> Void
    public init(_ action: @escaping (T) -> Void) {
        self.action = action
    }
}

public extension Inputing {
    func asInput() -> SimpleInput<InputType> {
        SimpleInput {
            self.input(value: $0)
        }
    }

    func asInput<T>(_ mapping: @escaping (T) -> InputType) -> SimpleInput<T> {
        SimpleInput {
            self.input(value: mapping($0))
        }
    }
}
