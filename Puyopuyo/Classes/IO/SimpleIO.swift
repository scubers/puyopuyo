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

public class SimpleIO<Value>: Inputing, Outputing, UniqueOutputable, OutputingModifier {
    public typealias InputType = Value
    public typealias OutputType = Value
    public var uniqueDisposable: Disposer?

    private var inputers = LinkList<Listener<Value>>() // [Listener<Value>]()

    public init() {}

    public func input(value: Value) {
        inputers.forEach { c in
            c.input.input(value: value)
        }
    }

//    public func outputing(_ block: @escaping (Value) -> Void) -> Disposer {
    public func subscribe<Subscriber>(_ subscriber: Subscriber) -> Disposer where Subscriber: Inputing, Value == Subscriber.InputType {
        let listener = Listener<Value>(input: Inputs { subscriber.input(value: $0) })
        inputers.append(listener)
        let id = listener.uuid.description
        return Disposers.create { [weak self] in
            self?.inputers.removeAll(where: { $0.uuid.description == id })
        }
    }
}
