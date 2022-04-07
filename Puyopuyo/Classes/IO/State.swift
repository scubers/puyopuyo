//
//  Stateful.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/30.
//

import Foundation

public class State<Value>: Outputing, Inputing, UniqueOutputable, OutputingModifier, SpecificValueable {
    public var uniqueDisposable: Disposer?

    public typealias OutputType = Value

    public typealias InputType = Value

    public typealias SpecificValue = Value

    public var specificValue: SpecificValue {
        set { value = newValue }
        get { value }
    }

    public init(_ value: Value) { _value = value }

    public init(value: Value) { _value = value }

    fileprivate init() {}

    public var value: Value {
        set { _value = newValue }
        get { return _value }
    }

    private var _value: Value! {
        didSet { inputers.forEach { $0.input.input(value: _value) } }
    }

    private var inputers = LinkList<Listener<Value>>()// [Listener<Value>]()

    /// Create a state without initial value, you can not use the value before set.
    /// Neither use keyPath to access value before set
    public static func unstable() -> State<Value> { State<Value>() }

    public func resend() { input(value: value) }

    public func input(value: InputType) { _value = value }

    public func outputing(_ block: @escaping (OutputType) -> Void) -> Disposer {
        if let value = _value {
            block(value)
        }
        let listener = Listener<Value>(input: Inputs(block))
        inputers.append(listener)
        let id = listener.uuid.description
        return Disposers.create { [weak self] in
            self?.inputers.removeAll(where: { $0.uuid.description == id })
        }
    }
}

public extension Inputing where Self: SpecificValueable, SpecificValue == InputType {
    func asInput<T>(_ kp: WritableKeyPath<InputType, T>) -> Inputs<T> {
        Inputs<T> { value in
            self.specificValue[keyPath: kp] = value
            self.input(value: self.specificValue)
        }
    }
}
