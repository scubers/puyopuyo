//
//  SimpleIO.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/17.
//

import Foundation

public class SimpleIO<Value>: Inputing, Outputing {
    public typealias InputType = Value
    public typealias OutputType = Value

    private var inputers = [SimpleInput<Value>]()

    public init() {}

    public func input(value: Value) {
        inputers.forEach { c in
            c.input(value: value)
        }
    }

    public func outputing(_ block: @escaping (Value) -> Void) -> Disposable {
        let inputer = SimpleInput(block)
        inputers.append(inputer)
        let id = inputer.uuid
        return Disposables.create { [weak self] in
            self?.inputers.removeAll(where: { $0.uuid == id })
        }
    }

    private var singleDisposable: Disposable?

    public func singleOutput(_ block: @escaping (Value) -> Void) {
        singleDisposable?.dispose()
        singleDisposable = outputing(block)
    }
}
