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
    public init(_ output: @escaping (T) -> Void) {
        self.action = output
    }
}
