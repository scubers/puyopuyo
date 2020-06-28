//
//  IO.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/8.
//

import Foundation

// MARK: - Unbinder

/// 解绑器
public protocol Unbinder {
    func py_unbind()
}

public extension Unbinder {
    func unbind(by: UnbinderBag, id: String = UUID().description) {
        by.py_setUnbinder(self, for: id)
    }
}

public protocol UnbinderBag {
    func py_setUnbinder(_ unbiner: Unbinder, for: String)
}

public struct UnbinderBags {
    public static func create() -> UnbinderBag { NSObject() }
}

// MARK: - Outputing, Inputing

/// 输出接口
public protocol Outputing {
    associatedtype OutputType
    func outputing(_ block: @escaping (OutputType) -> Void) -> Unbinder
}

/// 输入接口
public protocol Inputing {
    associatedtype InputType
    func input(value: InputType)
}

extension Outputing {
    /// 将输出接口绑定到对象Object中，并持续接收outputing值
    /// - Parameters:
    ///   - object: 绑定对象
    ///   - action: action description
    func catchObject<Object: UnbinderBag & AnyObject>(_ object: Object, _ action: @escaping (Object, OutputType) -> Void) -> Unbinder {
        return outputing { [weak object] s in
            if let object = object {
                action(object, s)
            }
        }
    }

    /// 对象销毁时则移除绑定
    @discardableResult
    public func safeBind<Object: UnbinderBag & AnyObject>(to object: Object, id: String = UUID().description, _ action: @escaping (Object, OutputType) -> Void) -> Unbinder {
        let unbinder = outputing { [weak object] v in
            if let object = object {
                action(object, v)
            }
        }
        object.py_setUnbinder(unbinder, for: id)
        return unbinder
    }

    /// 输出接口绑定到指定输入接口
    /// - Parameter input: input description
    public func send<Input: Inputing>(to input: Input) -> Unbinder where Input.InputType == OutputType {
        return outputing { v in
            input.input(value: v)
        }
    }

    public func send<Input: Inputing>(to inputs: [Input]) -> [Unbinder] where Input.InputType == OutputType {
        inputs.map { self.send(to: $0) }
    }

    public func setAction<Holder: NSObject>(_ action: OutputAction<Holder, OutputType>) {
        guard let holder = action.holder else { return }
        let unbinder = outputing(action.action)
        holder.py_setUnbinder(unbinder, for: "\(#function)_setActionToHolderKey")
    }
}

public struct OutputAction<Holder: NSObject, Value> {
    public var holder: Holder?
    public var action: (Value) -> Void
    public init(_ holder: Holder?, _ action: @escaping (Value) -> Void) {
        self.holder = holder
        self.action = action
    }
}

public extension Outputing where OutputType == Self {
    func outputing(_ block: @escaping (OutputType) -> Void) -> Unbinder {
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
    public static func create(_ block: @escaping () -> Void = {}) -> Unbinder {
        return UnbinderImpl(block)
    }
    
    public static func createBag() -> UnbinderBag {
        NSObject()
    }
}

// MARK: - NSObject unbinder impl

extension NSObject: UnbinderBag {
    public func py_setUnbinder(_ unbinder: Unbinder, for key: String) {
        py_unbinderContainer.setUnbinder(unbinder, for: key)
    }

    @discardableResult
    public func py_removeUnbinder(for key: String) -> Unbinder? {
        return py_unbinderContainer.removeUnbinder(for: key)
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

        func removeUnbinder(for key: String) -> Unbinder? {
            return unbinders.removeValue(forKey: key)
        }

        deinit {
            unbinders.forEach { _, unbinder in
                unbinder.py_unbind()
            }
        }
    }
}

// MARK: - Default impls

extension Optional: Outputing { public typealias OutputType = Wrapped? }

extension String: Outputing { public typealias OutputType = String }
extension Bool: Outputing { public typealias OutputType = Bool }
extension CGRect: Outputing { public typealias OutputType = CGRect }
extension UIEdgeInsets: Outputing { public typealias OutputType = UIEdgeInsets }
extension CGPoint: Outputing { public typealias OutputType = CGPoint }
extension CGSize: Outputing { public typealias OutputType = CGSize }
extension Array: Outputing { public typealias OutputType = Array }
extension Dictionary: Outputing { public typealias OutputType = Dictionary }
extension Date: Outputing { public typealias OutputType = Date }
extension URL: Outputing { public typealias OutputType = URL }
extension Data: Outputing { public typealias OutputType = Data }

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
extension UIKeyboardType: Outputing { public typealias OutputType = UIKeyboardType }
