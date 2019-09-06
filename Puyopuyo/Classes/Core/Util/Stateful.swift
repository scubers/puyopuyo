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

public protocol Outputing: PuyoExt {
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

extension Outputing where OutputType == Self {
    public func outputing(_ block: @escaping (OutputType) -> Void) -> Unbinder {
        block(self)
        return Unbinders.create {}
    }
}

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
        return map({$0})
    }
    
    public func some() -> State<Base.OutputType?> {
        let new = State<Base.OutputType?>(nil)
        _ = base.outputing { (value) in
            new.input(value: value)
        }
        return new
    }
    
    public func map<R>(_ block: @escaping (Base.OutputType) -> R) -> State<R> {
        let new = State<R>()
        _ = base.outputing { (value) in
            new.input(value: block(value))
        }
        return new
    }
    
    public func filter(_ filter: @escaping (Base.OutputType) -> Bool) -> State<Base.OutputType> {
        let new = State<Base.OutputType>()
        _ = base.outputing { (v) in
            if filter(v) {
                new.input(value: v)
            }
        }
        return new
    }
    
    public func ignore(_ condition: @escaping (Base.OutputType, Base.OutputType) -> Bool) -> State<Base.OutputType> {
        let new = State<Base.OutputType>()
        var last: Base.OutputType!
        _ = base.outputing { (v) in
            guard last != nil else {
                last = v
                new.input(value: v)
                return
            }
            let ignore = condition(last, v)
            last = v
            if !ignore {
                new.input(value: v)
            }
        }
        return new
    }
}

extension Yo where Base: Outputing, Base.OutputType: Equatable {
    public func distinct() -> State<Base.OutputType> {
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

extension Optional: Outputing { public typealias OutputType = Optional<Wrapped> }

extension String: Outputing { public typealias OutputType = String }
extension Bool: Outputing { public typealias OutputType = Bool }
extension CGRect: Outputing { public typealias OutputType = CGRect }
extension UIEdgeInsets: Outputing { public typealias OutputType = UIEdgeInsets }
extension CGPoint: Outputing { public typealias OutputType = CGPoint }
extension CGSize: Outputing { public typealias OutputType = CGSize }
extension Array: Outputing { public typealias OutputType = Array }
extension Dictionary: Outputing { public typealias OutputType = Dictionary }

extension UIImage: Outputing { public typealias OutputType = UIImage }
extension UIColor: Outputing { public typealias OutputType = UIColor }
extension UIFont: Outputing { public typealias OutputType = UIFont }
extension UIControl.State: Outputing { public typealias OutputType = UIControl.State }
extension UIControl.Event: Outputing { public typealias OutputType = UIControl.Event }
extension UIView.ContentMode: Outputing { public typealias OutputType = UIView.ContentMode }
extension NSTextAlignment: Outputing { public typealias OutputType = NSTextAlignment }

extension Int: Outputing { public typealias OutputType = Int }
extension CGFloat: Outputing { public typealias OutputType = CGFloat }
extension Double: Outputing { public typealias OutputType = Double }
extension Float: Outputing { public typealias OutputType = Float }
extension UInt: Outputing { public typealias OutputType = UInt }
extension Int32: Outputing { public typealias OutputType = Int32 }
extension UInt32: Outputing { public typealias OutputType = UInt32 }
extension Int64: Outputing { public typealias OutputType = Int64 }
extension UInt64: Outputing { public typealias OutputType = UInt64 }
