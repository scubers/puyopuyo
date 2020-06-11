//
//  SimpleInput.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/8.
//

import Foundation

public struct SimpleInput<T>: Inputing {
    public typealias InputType = T
    public var uuid: String = UUID().description
    public func input(value: SimpleInput<T>.InputType) {
        action(value)
    }

    private var action: (T) -> Void
    public init(_ output: @escaping (T) -> Void = {_ in }) {
        action = output
    }
}

public extension Inputing {
    func asInput() -> SimpleInput<InputType> {
        return SimpleInput { x in
            self.input(value: x)
        }
    }

    func asInput<T>(_ mapping: @escaping (T) -> InputType) -> SimpleInput<T> {
        return SimpleInput { x in
            self.input(value: mapping(x))
        }
    }
}
