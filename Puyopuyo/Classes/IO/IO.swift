//
//  IO.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/8.
//

import Foundation

// MARK: - Disposable

public typealias Unbinder = Disposer

// MARK: - Inputing

/// 输入接口
public protocol Inputing {
    associatedtype InputType
    func input(value: InputType)
}

// MARK: - Outputing

/// 输出接口
public protocol Outputing {
    associatedtype OutputType
    func subscribe<Subscriber>(_ subscriber: Subscriber) -> Disposer where Subscriber: Inputing, Subscriber.InputType == OutputType
}

public extension Outputing {
    func outputing(_ block: @escaping (OutputType) -> Void) -> Disposer {
        subscribe(Inputs(block))
    }

    func asOutput() -> Outputs<OutputType> {
        Outputs { i -> Disposer in
            self.outputing { v in
                i.input(value: v)
            }
        }
    }

    /// 对象销毁时则移除绑定
    @discardableResult
    func safeBind<Object: AutoDisposable>(to object: Object, id: String? = nil, _ action: @escaping (Object, OutputType) -> Void) -> Disposer {
        let disposer = outputing { [weak object] v in
            if let object = object {
                action(object, v)
            }
        }
        object.addDisposer(disposer, for: id)
        return disposer
    }

    /// 输出接口绑定到指定输入接口
    /// - Parameter input: input description
    func send<Input: Inputing>(to input: Input) -> Disposer where Input.InputType == OutputType {
        outputing(input.input(value:))
    }

    func send<Input: Inputing>(to inputs: [Input]) -> Disposer where Input.InputType == OutputType {
        let disposers = inputs.map { send(to: $0) }
        return Disposers.create {
            disposers.forEach { $0.dispose() }
        }
    }
}

public extension Outputing where OutputType == Self {
    func subscribe<Subscriber>(_ subscriber: Subscriber) -> Disposer where Subscriber: Inputing, Subscriber.InputType == OutputType {
        subscriber.input(value: self)
        return Disposers.create()
    }
}

// MARK: - Default impls

extension Optional: Outputing { public typealias OutputType = Optional }

extension String: Outputing { public typealias OutputType = String }
extension Bool: Outputing { public typealias OutputType = Bool }

extension Int: Outputing { public typealias OutputType = Int }
extension CGFloat: Outputing { public typealias OutputType = CGFloat }
extension Double: Outputing { public typealias OutputType = Double }
extension Float: Outputing { public typealias OutputType = Float }
extension UInt: Outputing { public typealias OutputType = UInt }
extension Int32: Outputing { public typealias OutputType = Int32 }
extension UInt32: Outputing { public typealias OutputType = UInt32 }
extension Int64: Outputing { public typealias OutputType = Int64 }
extension UInt64: Outputing { public typealias OutputType = UInt64 }

extension Date: Outputing { public typealias OutputType = Date }
extension URL: Outputing { public typealias OutputType = URL }
extension Data: Outputing { public typealias OutputType = Data }

extension Array: Outputing { public typealias OutputType = Array }
extension Dictionary: Outputing { public typealias OutputType = Dictionary }

extension NSTextAlignment: Outputing { public typealias OutputType = NSTextAlignment }

extension CGRect: Outputing { public typealias OutputType = CGRect }
extension CGPoint: Outputing { public typealias OutputType = CGPoint }
extension CGSize: Outputing { public typealias OutputType = CGSize }

extension UIEdgeInsets: Outputing { public typealias OutputType = UIEdgeInsets }
extension UIImage: Outputing {
    public func subscribe<Subscriber>(_ subscriber: Subscriber) -> Disposer where Subscriber: Inputing, UIImage == Subscriber.InputType {
        subscriber.input(value: self)
        return Disposers.create()
    }

    public typealias OutputType = UIImage
}

extension UIColor: Outputing {
    public func subscribe<Subscriber>(_ subscriber: Subscriber) -> Disposer where Subscriber: Inputing, UIColor == Subscriber.InputType {
        subscriber.input(value: self)
        return Disposers.create()
    }

    public typealias OutputType = UIColor
}

extension UIFont: Outputing {
    public func subscribe<Subscriber>(_ subscriber: Subscriber) -> Disposer where Subscriber: Inputing, UIFont == Subscriber.InputType {
        subscriber.input(value: self)
        return Disposers.create()
    }

    public typealias OutputType = UIFont
}

extension UIControl.State: Outputing { public typealias OutputType = UIControl.State }
extension UIControl.Event: Outputing { public typealias OutputType = UIControl.Event }
extension UIView.ContentMode: Outputing { public typealias OutputType = UIView.ContentMode }
extension UIKeyboardType: Outputing { public typealias OutputType = UIKeyboardType }
