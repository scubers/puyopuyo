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

public extension Unbinder {
    public static func create(_ block: @escaping () -> Void) -> Unbinder {
        return UnbinderImpl(block)
    }
}

public protocol Stateful {
    associatedtype StateType
    func py_bind(stateChange block: @escaping (StateType) -> Void) -> Unbinder
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
    
    
    
    private init() {
        
    }
    
    deinit {
        onDestroy()
    }
    
    private var onDestroy: () -> Void = {}

    private func post(value: T) {
        callees.forEach { (x) in
            x.block(value)
        }
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
    
    private let block: () -> Void
    init(_ block: @escaping () -> Void) {
        self.block = block
    }
    func py_unbind() {
        block()
    }
}

extension NSObject {
    func py_setUnbinder(_ unbinder: Unbinder, for key: String) {
        let container = py_unbinderContainer
        let old = container.object(forKey: key as NSString)
        if let old = old as? UnbinderImpl {
            old.py_unbind()
        }
        let rac = UnbinderImpl {
            unbinder.py_unbind()
        }
        container.setObject(rac, forKey: key as NSString)
    }
    
    private static var puyopuyo_unbinderContainerKey = "puyopuyo_disposerContainerKey"
    private var py_unbinderContainer: NSMutableDictionary {
        var dict = objc_getAssociatedObject(self, &NSObject.puyopuyo_unbinderContainerKey)
        if dict == nil {
            dict = NSMutableDictionary()
            objc_setAssociatedObject(self, &NSObject.puyopuyo_unbinderContainerKey, dict, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return dict as! NSMutableDictionary
    }
}

