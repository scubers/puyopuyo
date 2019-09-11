//
//  IO.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/8.
//

import Foundation

// MARK: - Extension
public struct Yo<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol PuyopuyoExt {
    associatedtype PuyopuyoExtType
    var yo: PuyopuyoExtType {get}
}

extension PuyopuyoExt {
    public var yo: Yo<Self> {
        return Yo(self)
    }
}

// MARK: - Unbinder
public protocol Unbinder {
    func py_unbind()
}

// MARK: - Outputing, Inputing
public protocol Outputing: PuyopuyoExt {
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
    
    /// 对象销毁时则移除绑定
    @discardableResult
    public func safeBind<Object: NSObject>(to object: Object, id: String, _ action: @escaping (Object, OutputType) -> Void) -> Unbinder {
        let unbinder = outputing { [weak object] (v) in
            if let object = object {
                action(object, v)
            }
        }
        object.py_setUnbinder(unbinder, for: id)
        return unbinder
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
        return Unbinders.create()
    }
}

class UnbinderImpl: NSObject, Unbinder {
    
    private var block: () -> Void
    
    init(_ block: @escaping () -> Void) {
        self.block = block
    }
    
    func py_unbind() {
        block()
        block = {}
    }
}

public struct Unbinders {
    private init() {}
    public static func create(_ block: @escaping () -> Void) -> Unbinder {
        return UnbinderImpl(block)
    }
    public static func create() -> Unbinder {
        return UnbinderImpl({})
    }
}

// MARK: - NSObject unbinder impl
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

// MARK: - Default impls

extension Optional: Outputing { public typealias OutputType = Optional<Wrapped> }

extension String: Outputing { public typealias OutputType = String }
extension Bool: Outputing { public typealias OutputType = Bool }
extension CGRect: Outputing { public typealias OutputType = CGRect }
extension UIEdgeInsets: Outputing { public typealias OutputType = UIEdgeInsets }
extension CGPoint: Outputing { public typealias OutputType = CGPoint }
extension CGSize: Outputing { public typealias OutputType = CGSize }
extension Array: Outputing { public typealias OutputType = Array }
extension Dictionary: Outputing { public typealias OutputType = Dictionary }

extension Int: Outputing { public typealias OutputType = Int }
extension CGFloat: Outputing { public typealias OutputType = CGFloat }
extension Double: Outputing { public typealias OutputType = Double }
extension Float: Outputing { public typealias OutputType = Float }
extension UInt: Outputing { public typealias OutputType = UInt }
extension Int32: Outputing { public typealias OutputType = Int32 }
extension UInt32: Outputing { public typealias OutputType = UInt32 }
extension Int64: Outputing { public typealias OutputType = Int64 }
extension UInt64: Outputing { public typealias OutputType = UInt64 }

extension UIImage: Outputing { public typealias OutputType = UIImage }
extension UIColor: Outputing { public typealias OutputType = UIColor }
extension UIFont: Outputing { public typealias OutputType = UIFont }
extension UIControl.State: Outputing { public typealias OutputType = UIControl.State }
extension UIControl.Event: Outputing { public typealias OutputType = UIControl.Event }
extension UIView.ContentMode: Outputing { public typealias OutputType = UIView.ContentMode }
extension NSTextAlignment: Outputing { public typealias OutputType = NSTextAlignment }
