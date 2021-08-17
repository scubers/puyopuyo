//
//  IO.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/8.
//

import Foundation

// MARK: - Disposable

/// 解绑器
public protocol Disposable {
    func dispose()
}

public extension Disposable {
    func unbind(by: DisposableBag, id: String = UUID().description) {
        by.addDisposable(self, for: id)
    }
}

public protocol DisposableBag {
    func addDisposable(_ unbiner: Disposable, for: String)
}

public enum DisposableBags {
    public static func create() -> DisposableBag { NSObject() }
}

// MARK: - Outputing, Inputing

/// 输出接口
public protocol Outputing {
    associatedtype OutputType
    func outputing(_ block: @escaping (OutputType) -> Void) -> Disposable
}

/// 输入接口
public protocol Inputing {
    associatedtype InputType
    func input(value: InputType)
}

public extension Outputing {
    /// 将输出接口绑定到对象Object中，并持续接收outputing值
    /// - Parameters:
    ///   - object: 绑定对象
    ///   - action: action description
    internal func catchObject<Object: DisposableBag & AnyObject>(_ object: Object, _ action: @escaping (Object, OutputType) -> Void) -> Disposable {
        return outputing { [weak object] s in
            if let object = object {
                action(object, s)
            }
        }
    }

    /// 对象销毁时则移除绑定
    @discardableResult
    func safeBind<Object: DisposableBag & AnyObject>(to object: Object, id: String = UUID().description, _ action: @escaping (Object, OutputType) -> Void) -> Disposable {
        let Disposable = outputing { [weak object] v in
            if let object = object {
                action(object, v)
            }
        }
        object.addDisposable(Disposable, for: id)
        return Disposable
    }

    /// 输出接口绑定到指定输入接口
    /// - Parameter input: input description
    func send<Input: Inputing>(to input: Input) -> Disposable where Input.InputType == OutputType {
        return outputing { v in
            input.input(value: v)
        }
    }

    func send<Input: Inputing>(to inputs: [Input]) -> [Disposable] where Input.InputType == OutputType {
        inputs.map { self.send(to: $0) }
    }

    func setAction<Holder: NSObject>(_ action: OutputAction<Holder, OutputType>) {
        guard let holder = action.holder else { return }
        let Disposable = outputing(action.action)
        holder.addDisposable(Disposable, for: "\(#function)_setActionToHolderKey")
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
    func outputing(_ block: @escaping (OutputType) -> Void) -> Disposable {
        block(self)
        return Disposables.create()
    }
}

class DisposableImpl: NSObject, Disposable {
    private var block: () -> Void

    init(_ block: @escaping () -> Void) {
        self.block = block
    }

    func dispose() {
        block()
        block = {}
    }
}

public struct Disposables {
    private init() {}
    public static func create(_ block: @escaping () -> Void = {}) -> Disposable {
        return DisposableImpl(block)
    }

    public static func createBag() -> DisposableBag {
        NSObject()
    }
}

// MARK: - NSObject Disposable impl

extension NSObject: DisposableBag {
    public func addDisposable(_ Disposable: Disposable, for key: String) {
        py_DisposableContainer.setDisposable(Disposable, for: key)
    }

    @discardableResult
    private func py_removeDisposable(for key: String) -> Disposable? {
        return py_DisposableContainer.removeDisposable(for: key)
    }

    private static var puyopuyo_DisposableContainerKey = "puyoDisposable"
    private var py_DisposableContainer: DisposableContainer {
        var container = objc_getAssociatedObject(self, &NSObject.puyopuyo_DisposableContainerKey)
        if container == nil {
            container = DisposableContainer()
            objc_setAssociatedObject(self, &NSObject.puyopuyo_DisposableContainerKey, container, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return container as! DisposableContainer
    }

    private class DisposableContainer: NSObject {
        private var Disposables = [String: Disposable]()

        func setDisposable(_ Disposable: Disposable, for key: String) {
            let old = Disposables[key]
            old?.dispose()
            Disposables[key] = Disposable
        }

        func removeDisposable(for key: String) -> Disposable? {
            return Disposables.removeValue(forKey: key)
        }

        deinit {
            Disposables.forEach { _, Disposable in
                Disposable.dispose()
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
