//
//  Stateful.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/30.
//

import Foundation

public protocol Unbinder {
    func py_unbind()
}

public class Unbinders {
    private init() {}
    public static func create(_ block: @escaping () -> Void) -> Unbinder {
        return UnbinderImpl(block)
    }
}

public protocol Outputing {
    associatedtype OutputType
    func outputing(_ block: @escaping (OutputType) -> Void) -> Unbinder
}

public protocol Inputing {
    associatedtype InputType
    func input(value: InputType)
}

extension Outputing {
    public func safeBind<Object: AnyObject>(_ object: Object, _ action: @escaping (Object, OutputType) -> Void) -> Unbinder {
        return outputing { [weak object] (s) in
            if let object = object {
                action(object, s)
            }
        }
    }
    
    public func send<Input: Inputing>(to input: Input) -> Unbinder where Input.InputType == OutputType {
        return outputing { (v) in
            input.input(value: v)
        }
    }
    
}

public typealias _St = State

public class State<Value>: Outputing, Inputing {
    
    public typealias OutputType = Value
    public typealias InputType = Value
    
    public init(_ value: Value) {
        self._value = value
    }
    
    private init() {}
    
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
    
    private class Callee<T> {
        var block: (T) -> Void
        init(_ block: @escaping (T) -> Void) {
            self.block = block
        }
    }

}

extension State {
    public func optional() -> State<Value?> {
        let new = State<Value?>(nil)
        _ = outputing { (value) in
            new.input(value: value)
        }
        return new
    }
    
    public func map<R>(_ block: @escaping (Value) -> R) -> State<R> {
        let newState = State<R>()
        _ = outputing { (value) in
            newState.input(value: block(value))
        }
        return newState
    }
    
    public func filter(_ filter: @escaping (Value) -> Bool) -> State<Value> {
        let new = State<Value>()
        _ = self.outputing { (v) in
            if filter(v) {
                new.input(value: v)
            }
        }
        return new
    }
    
    public func ignore(_ condition: @escaping (Value, Value) -> Bool) -> State<Value> {
        let new = State<Value>()
        var last: Value!
        let unbinder = self.outputing { (v) in
            guard last != nil else {
                last = v
                return
            }
            let ignore = condition(last, v)
            last = v
            if !ignore {
                new.input(value: v)
            }
        }
        new.onDestroy = {
            unbinder.py_unbind()
        }
        return new
    }
    
}

extension State where Value: Equatable {
    public func distinct() -> State<Value> {
        return ignore({ $0 == $1 })
    }
}

private class UnbinderImpl: NSObject, Unbinder {
    
    private var block: () -> Void
    init(_ block: @escaping () -> Void) {
        self.block = block
    }
    func py_unbind() {
        block()
        block = {}
    }
}

extension NSObject {
    public func py_setUnbinder(_ unbinder: Unbinder, for key: String) {
        py_unbinderContainer.setUnbinder(unbinder, for: key)
    }
    
    private static var puyopuyo_unbinderContainerKey = "puyoUnbinder"
    private var py_unbinderContainer: UnbinderContainer {
        var container = objc_getAssociatedObject(self, &NSObject.puyopuyo_unbinderContainerKey)
        if container == nil {
            container = UnbinderContainer(name: NSStringFromClass(type(of: self)), address: "")
            objc_setAssociatedObject(self, &NSObject.puyopuyo_unbinderContainerKey, container, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return container as! UnbinderContainer
    }
    
    private class UnbinderContainer: NSObject {
        private var unbinders = [String: Unbinder]()
        private var name: String = ""
        private var address: String = ""
        convenience init(name: String, address: String) {
            self.init()
            self.name = name
            self.address = address
        }
        
        func setUnbinder(_ unbinder: Unbinder, for key: String) {
            let old = unbinders[key]
            old?.py_unbind()
            unbinders[key] = unbinder
        }
        
        deinit {
            #if DEV
            print("container for \(name) deallcating!!")
            #endif
            unbinders.forEach { (_, unbinder) in
                unbinder.py_unbind()
            }
        }
    }
    
}

public struct SimpleInput<T>: Inputing {
    public typealias InputType = T
    public func input(value: SimpleInput<T>.InputType) {
        action(value)
    }
    private var action: (T) -> Void
    public init(_ output: @escaping (T) -> Void) {
        self.action = output
    }
}
