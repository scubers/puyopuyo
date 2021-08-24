//
//  SimpleInput.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/8.
//

import Foundation

public typealias SimpleInput = Inputs
public struct Inputs<T>: Inputing {
    public typealias InputType = T
    public func input(value: Inputs<T>.InputType) {
        action(value)
    }

    private let action: (T) -> Void
    public init(_ action: @escaping (T) -> Void) {
        self.action = action
    }
}

public extension Inputing {
    func asInput() -> Inputs<InputType> {
        Inputs {
            self.input(value: $0)
        }
    }

    func asInput<T>(_ mapping: @escaping (T) -> InputType) -> Inputs<T> {
        Inputs {
            self.input(value: mapping($0))
        }
    }
}
