//
//  Stateful.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/30.
//

import Foundation

public typealias _St = State

public class State<Value>: Outputing, Inputing {
    public typealias OutputType = Value

    public typealias InputType = Value

    public init(_ value: Value) {
        _value = value
    }

    fileprivate init() {}

    public var value: Value {
        set {
            _value = newValue
        }
        get {
            return _value
        }
    }

    private var _value: Value! {
        didSet {
            inputers.forEach { $0.input(value: _value) }
        }
    }

    private var inputers = [SimpleInput<Value>]()

    /// 返回一个没有初始值的state，此时如果调用value方法会崩溃
    public static func unstable() -> State<Value> {
        return State<Value>()
    }

    public func resend() {
        input(value: value)
    }

    public func input(value: State<Value>.InputType) {
        _value = value
    }

    public func outputing(_ block: @escaping (State<Value>.OutputType) -> Void) -> Unbinder {
        if let value = _value {
            block(value)
        }
        let inputer = SimpleInput(block)
        inputers.append(inputer)
        let id = inputer.uuid
        return UnbinderImpl { [weak self] in
            self?.inputers.removeAll(where: { $0.uuid == id })
        }
    }

    private var singleUnbinder: Unbinder?

    public func singleOutput(_ block: @escaping (Value) -> Void) {
        singleUnbinder?.py_unbind()
        singleUnbinder = outputing(block)
    }
}

// extension Yo where Base: Outputing {
extension SimpleOutput {
    public func state() -> State<OutputType> {
        let new = State<OutputType>()
        _ = outputing({ v in
            new.input(value: v)
        })
        return new
    }

    public func someState() -> State<OutputType?> {
        let new = State<OutputType?>()
        _ = outputing({ v in
            new.input(value: v)
        })
        return new
    }
}
