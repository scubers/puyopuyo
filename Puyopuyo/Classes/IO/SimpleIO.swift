//
//  SimpleIO.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/17.
//

import Foundation

struct Listener<Value> {
    let uuid = UUID()
    let input: SimpleInput<Value>
}

public class SimpleIO<Value>: Inputing, Outputing {
    public typealias InputType = Value
    public typealias OutputType = Value

    private var inputers = [Listener<Value>]()

    public init() {}

    public func input(value: Value) {
        inputers.forEach { c in
            c.input.input(value: value)
        }
    }

    public func outputing(_ block: @escaping (Value) -> Void) -> Disposable {
//        let inputer = SimpleInput(block)
        let listener = Listener<Value>(input: SimpleInput(block))
        inputers.append(listener)
        let id = listener.uuid.description
        return Disposables.create { [weak self] in
            self?.inputers.removeAll(where: { $0.uuid.description == id })
        }
    }

    private var singleDisposable: Disposable?

    public func singleOutput(_ block: @escaping (Value) -> Void) {
        singleDisposable?.dispose()
        singleDisposable = outputing(block)
    }
}
