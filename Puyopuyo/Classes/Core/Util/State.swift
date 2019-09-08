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
        self._value = value
    }
    
    fileprivate init() {}
    
    deinit {
        onDestroy()
    }

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
            self.callees.forEach {
                $0.block(_value)
            }
        }
    }
    
    private var callees = [Callee<Value>]()
    
    private var onDestroy: () -> Void = {}
    
    /// 返回一个没有初始值的state，此时如果调用value方法会崩溃
    public static func unstable() -> State<Value> {
        return State<Value>()
    }
    
    public func resend() {
        input(value: value)
    }
    
    public func input(value: State<Value>.InputType) {
        self._value = value
    }
    
    public func outputing(_ block: @escaping (State<Value>.OutputType) -> Void) -> Unbinder {
        if let value = _value {
            block(value)
        }
        let callee = Callee(block)
        callees.append(callee)
        let pointer = Unmanaged.passUnretained(callee).toOpaque()
        return UnbinderImpl { [weak self] in
            self?.callees.removeAll(where: { Unmanaged.passUnretained($0).toOpaque() == pointer })
        }
    }
    
    private var singleUnbinder: Unbinder?
    
    public func singleOutput(_ block: @escaping (Value) -> Void) {
        singleUnbinder?.py_unbind()
        singleUnbinder = outputing(block)
    }
    
    private class Callee<T> {
        var block: (T) -> Void
        init(_ block: @escaping (T) -> Void) {
            self.block = block
        }
    }
}

extension Yo where Base: Outputing {
    
    public func state() -> State<Base.OutputType> {
        let new = State<Base.OutputType>()
        _ = base.outputing({ (v) in
            new.input(value: v)
        })
        return new
    }
    
    public func someState() -> State<Base.OutputType?> {
        let new = State<Base.OutputType?>()
        _ = base.outputing({ (v) in
            new.input(value: v)
        })
        return new
    }
}
