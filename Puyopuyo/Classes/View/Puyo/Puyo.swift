//
//  Puyo.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/23.
//

import Foundation

public protocol CGFloatable {
    var cgFloatValue: CGFloat { get }
}

extension CGFloat: CGFloatable { public var cgFloatValue: CGFloat { return self } }
extension Int: CGFloatable { public var cgFloatValue: CGFloat { return CGFloat(self) } }
extension Int32: CGFloatable { public var cgFloatValue: CGFloat { return CGFloat(self) } }
extension Int64: CGFloatable { public var cgFloatValue: CGFloat { return CGFloat(self) } }
extension UInt: CGFloatable { public var cgFloatValue: CGFloat { return CGFloat(self) } }
extension UInt32: CGFloatable { public var cgFloatValue: CGFloat { return CGFloat(self) } }
extension UInt64: CGFloatable { public var cgFloatValue: CGFloat { return CGFloat(self) } }
extension Double: CGFloatable { public var cgFloatValue: CGFloat { return CGFloat(self) } }
extension Float: CGFloatable { public var cgFloatValue: CGFloat { return CGFloat(self) } }

public class Puyo<T: AnyObject> {
    public private(set) var view: T

    public init(_ view: T) {
        self.view = view
    }
}

public extension Puyo where T: UnbinderBag {
    /// 接收一个outputing，并且绑定到view上，持续接收action
    /// - Parameters:
    ///   - state: state description
    ///   - action: action description
    @discardableResult
    func on<O: Outputing, R>(_ state: O, _ action: @escaping (T, R) -> Void) -> Self where O.OutputType == R {
        view.py_setUnbinder(state.catchObject(view) { v, r in
            action(v, r)
        }, for: UUID().description)
        return self
    }
}

public extension Puyo where T: UIView {
    func setNeedsLayout() {
        view.py_setNeedsLayout()
    }

    static func ensureInactivate(_ view: UIView, _ msg: String = "") {
        assert(!view.py_measure.activated, msg)
    }

    @discardableResult
    func assign(to pointer: UnsafeMutablePointer<T>) -> Self {
        pointer.pointee = view
        return self
    }

    /// 接收一个outputing，并且绑定到view上，持续接收action，后，重新布局
    /// - Parameters:
    ///   - state: state description
    ///   - action: action description
    @discardableResult
    func viewUpdate<O: Outputing, R>(on state: O, _ action: @escaping (T, R) -> Void) -> Self where O.OutputType == R {
        return on(state) { v, r in
            action(v, r)
            v.py_setNeedsLayout()
        }
    }

    @discardableResult
    func viewUpdate<O: Outputing, R, Object: AnyObject>(on state: O, to object: Object, _ action: @escaping (Object, T, R) -> Void) -> Self where O.OutputType == R {
        return viewUpdate(on: state) { [weak object] t, r in
            if let o = object {
                action(o, t, r)
            }
        }
    }
}

public extension Puyo where T: ViewDisplayable {
    @discardableResult
    func attach(_ parent: UIView? = nil, _ block: (T) -> Void = { _ in }) -> Puyo<T> {
        block(view)
        parent?.addSubview(view.dislplayView)
        return self
    }
}

public typealias PuyoBlock = (UIView) -> Void

public protocol PuyoAttacher {
    associatedtype Holder: ViewDisplayable
    func attach(_ parent: ViewDisplayable?, _ block: PuyoBlock) -> Puyo<Holder>
}

public protocol ViewDisplayable: class {
    var dislplayView: UIView { get }
}

extension UIView: ViewDisplayable {
    public var dislplayView: UIView { self }
}

extension UIViewController: ViewDisplayable {
    public var dislplayView: UIView { view }
}

extension PuyoAttacher where Self: ViewDisplayable {
    @discardableResult
    public func attach(_ parent: ViewDisplayable? = nil, _ block: PuyoBlock = { _ in }) -> Puyo<Self> {
        let link = Puyo(self)
        block(dislplayView)
        parent?.dislplayView.addSubview(dislplayView)
        return link
    }
}

extension UIViewController: PuyoAttacher {}

extension UIView: PuyoAttacher {
    func py_setNeedsLayout() {
        setNeedsLayout()
        if let superview = superview, BoxUtil.isBox(superview) {
            superview.setNeedsLayout()
        }
    }

    func py_setNeedsLayoutIfMayBeWrap() {
        if py_measure.size.maybeWrap() {
            py_setNeedsLayout()
        }
    }
}
