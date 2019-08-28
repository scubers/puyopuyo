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

public protocol ValueOutputing {
    associatedtype OutputType
    func receiveOutput(_ block: @escaping (OutputType) -> Void) -> Unbinder
}

public protocol ValueInputing {
    associatedtype InputType
    func input(value: InputType)
}

public typealias Statefule = (ValueOutputing & ValueInputing)

extension ValueOutputing {
    public func safeBind<Object: AnyObject>(_ object: Object, _ action: @escaping (Object, OutputType) -> Void) -> Unbinder {
        return receiveOutput { [weak object] (s) in
            if let object = object {
                action(object, s)
            }
        }
    }
    
    public func py_bind<Input: ValueInputing>(to output: Input) -> Unbinder where Input.InputType == OutputType {
        return receiveOutput { (v) in
            output.input(value: v)
        }
    }
    
}

public typealias _S = State

public class State<T>: ValueOutputing, ValueInputing {
    
    public func input(value: State<T>.InputType) {
        self._value = value
    }
    
    public func receiveOutput(_ block: @escaping (State<T>.OutputType) -> Void) -> Unbinder {
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
    
    public typealias OutputType = T
    
    public typealias InputType = T
    
    public var value: T {
        set {
            _value = newValue
        }
        get {
            return _value
        }
    }
    
    private var _value: T! {
        didSet {
            self.callees.forEach {
                $0.block(_value)
            }
        }
    }
    
    public init(_ value: T) {
        self._value = value
    }
    
    private init() {}
    
    deinit {
        onDestroy()
    }
    
    var onDestroy: () -> Void = {}

    private class Callee<T> {
        var block: (T) -> Void
        init(_ block: @escaping (T) -> Void) {
            self.block = block
        }
    }
    
    private var callees = [Callee<T>]()

}

extension State {
    public func optional() -> State<OutputType?> {
        let new = State<OutputType?>(nil)
        let unbinder = receiveOutput { (value) in
            new.input(value: value)
        }
        new.onDestroy = {
            unbinder.py_unbind()
        }
        return new
    }
    
    public func map<S: ValueInputing, R>(_ block: @escaping (T) -> R) -> S where S.InputType == R {
        let newState = State<R>()
        let unbinder = receiveOutput { (value) in
            newState.input(value: block(value))
        }
        newState.onDestroy = {
            unbinder.py_unbind()
        }
        return newState as! S
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
            container = UnbinderContainer()
            objc_setAssociatedObject(self, &NSObject.puyopuyo_unbinderContainerKey, container, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return container as! UnbinderContainer
    }
    
    private class UnbinderContainer: NSObject {
        private var unbinders = [String: Unbinder]()
        
        func setUnbinder(_ unbinder: Unbinder, for key: String) {
            let old = unbinders[key]
            old?.py_unbind()
            unbinders[key] = unbinder
        }
        
        deinit {
            unbinders.forEach { (_, unbinder) in
                unbinder.py_unbind()
            }
        }
    }
    
}

public struct SimpleInput<T>: ValueInputing {
    public typealias InputType = T
    public func input(value: SimpleInput<T>.InputType) {
        action(value)
    }
    private var action: (T) -> Void
    public init(_ output: @escaping (T) -> Void) {
        self.action = output
    }
}
