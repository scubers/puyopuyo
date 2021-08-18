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
        didSet { inputers.forEach { $0.input.input(value: _value) } }
    }

    private var inputers = [Listener<Value>]()

    /// 返回一个没有初始值的state，此时如果调用value方法会崩溃
    public static func unstable() -> State<Value> { State<Value>() }

    public func resend() { input(value: value) }

    public func input(value: InputType) { _value = value }

    public func outputing(_ block: @escaping (OutputType) -> Void) -> Disposable {
        if let value = _value {
            block(value)
        }
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

    public func setState(_ state: (inout Value) -> Void) {
        var v = value
        state(&v)
        resend()
    }
}
