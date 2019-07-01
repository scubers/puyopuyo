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

public protocol Stateful {
    associatedtype StateType
    func py_bind(stateChange block: @escaping (StateType) -> Void) -> Unbinder
    func py_change(_ state: StateType)
}

extension Stateful {
    public func safeBind<Object: AnyObject>(_ object: Object, _ action: @escaping (Object, StateType) -> Void) -> Unbinder {
        return py_bind(stateChange: { [weak object] (s) in
            if let object = object {
                action(object, s)
            }
        })
    }
}

public class State<T>: Stateful {

    public typealias StateType = T
    
    public var value: T! {
        didSet {
            self.callees.forEach {
                $0.block(value)
            }
        }
    }
    
    public init(value: T) {
        self.value = value
    }
    
    private init() {}
    
    deinit {
        onDestroy()
    }
    
    private var onDestroy: () -> Void = {}

    private func post(value: T) {
        callees.forEach { (x) in
            x.block(value)
        }
    }
    
    public func py_change(_ state: T) {
        value = state
    }
    
    private class Callee<T> {
        var block: (T) -> Void
        init(_ block: @escaping (T) -> Void) {
            self.block = block
        }
    }
    
    private var callees = [Callee<T>]()

    public func py_bind(stateChange block: @escaping (T) -> Void) -> Unbinder {
        if let value = value {
            block(value)
        }
        let callee = Callee(block)
        callees.append(callee)
        return UnbinderImpl {
            self.callees.removeAll(where: { $0 === callee})
        }
    }
    
    public func map<S: Stateful, R>(_ block: @escaping (T) -> R) -> S where S.StateType == R {
        let newState = State<R>()
        let unbinder = py_bind { (value) in
            newState.post(value: block(value))
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
    
    private static var puyopuyo_unbinderContainerKey = "puyopuyo_unbinderContainerKey"
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
