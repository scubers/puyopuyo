//
//  SimpleIO.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/17.
//

import Foundation

struct Listener<Value> {
    let uuid = UUID()
    let input: Inputs<Value>
}

public class SimpleIO<Value>: Inputing, Outputing, UniqueOutputable {
    public typealias InputType = Value
    public typealias OutputType = Value
    public var uniqueDisposable: Disposer?

    private var inputers = [Listener<Value>]()

    public init() {}

    public func input(value: Value) {
        inputers.forEach { c in
            c.input.input(value: value)
        }
    }

    public func outputing(_ block: @escaping (Value) -> Void) -> Disposer {
        let listener = Listener<Value>(input: Inputs(block))
        inputers.append(listener)
        let id = listener.uuid.description
        return Disposers.create { [weak self] in
            self?.inputers.removeAll(where: { $0.uuid.description == id })
        }
    }
}
