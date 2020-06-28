//
//  Stateful.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/30.
//

import Foundation

public class State<Value>: Outputing, Inputing {
    public typealias OutputType = Value

    public typealias InputType = Value

    public init(_ value: Value) { _value = value }

    public init(value: Value) { _value = value }

    fileprivate init() {}

    public var value: Value {
        set { _value = newValue }
        get { return _value }
    }

    private var _value: Value! {
        didSet { inputers.forEach { $0.input(value: _value) } }
    }

    private var inputers = [SimpleInput<Value>]()

    /// 返回一个没有初始值的state，此时如果调用value方法会崩溃
    public static func unstable() -> State<Value> { State<Value>() }

    public func resend() { input(value: value) }

    public func input(value: State<Value>.InputType) { _value = value }

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

    public func setState(_ state: (inout Value) -> Void) {
        var v = value
        state(&v)
        value = v
    }

    public var binding: StateBinding<Value> { StateBinding(output: asOutput()) }
}

// MARK: - PState
@propertyWrapper public struct PState<Value>: Outputing, Inputing {
    private let state: State<Value>
    public init(wrappedValue value: Value) {
        state = State(value)
    }

    public func outputing(_ block: @escaping (Value) -> Void) -> Unbinder {
        state.outputing(block)
    }

    public func input(value: Value) {
        state.input(value: value)
    }

    public var wrappedValue: Value {
        get { state.value }
        set { state.value = newValue }
    }

    public var projectedValue: StateBinding<Value> { StateBinding(output: state.asOutput()) }

    public func setState(_ block: (inout Value) -> Void) {
        state.setState(block)
    }
}

// MARK: - StateBinding
@dynamicMemberLookup public struct StateBinding<Value>: Outputing {
    public typealias OutputType = Value
    var output: SimpleOutput<Value>
    public subscript<Subject>(dynamicMember member: KeyPath<Value, Subject>) -> StateBinding<Subject> {
        StateBinding<Subject>(output: output.map(member))
    }

    public func outputing(_ block: @escaping (OutputType) -> Void) -> Unbinder {
        output.outputing(block)
    }
}

public extension StateBinding where Value: PuyoOptionalType {
    subscript<Subject>(dynamicMember member: KeyPath<Value.PuyoWrappedType, Subject>) -> StateBinding<Subject?> {
        StateBinding<Subject?>(
            output: output.map {
                if let v = $0.puyoWrapValue {
                    return v[keyPath: member]
                } else {
                    return nil
                }
            }
        )
    }
}

// MARK: - Extensions

public extension PuyoOptionalType {
    subscript<Subject>(dynamicMember member: KeyPath<PuyoWrappedType, Subject>) -> Subject? {
        if let v = puyoWrapValue {
            return v[keyPath: member]
        }
        return nil
    }
}

public extension Outputing {
    var binding: StateBinding<OutputType> { .init(output: asOutput()) }
}
