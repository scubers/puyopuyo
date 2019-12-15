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

public class Puyo<T: UIView> {
    public private(set) var view: T

    public init(_ view: T) {
        self.view = view
    }

    func setNeedsLayout() {
        view.py_setNeedsLayout()
    }

    @discardableResult
    public func attach(_ parent: UIView? = nil, _ block: ((T) -> Void)? = nil) -> Puyo<T> {
        block?(view)
        parent?.addSubview(view)
        return self
    }

    static func ensureInactivate(_ view: UIView, _ msg: String = "") {
        assert(!view.py_measure.activated, msg)
    }

    @discardableResult
    public func on<O: Outputing, R>(_ state: O, _ action: @escaping (T, R) -> Void) -> Self where O.OutputType == R {
        view.py_setUnbinder(state.safeBind(view, { v, r in
            action(v, r)
        }), for: UUID().description)
        return self
    }

    @discardableResult
    public func viewUpdate<O: Outputing, R>(on state: O, _ action: @escaping (T, R) -> Void) -> Self where O.OutputType == R {
        return on(state, { v, r in
            action(v, r)
            v.py_setNeedsLayout()
        })
    }

    @discardableResult
    public func viewUpdate<O: Outputing, R, Object: AnyObject>(on state: O, to object: Object, _ action: @escaping (Object, T, R) -> Void) -> Self where O.OutputType == R {
        return viewUpdate(on: state) { [weak object] t, r in
            if let o = object {
                action(o, t, r)
            }
        }
    }
}

public typealias PuyoBlock = (UIView) -> Void

public protocol PuyoAttacher {
    associatedtype Holder: UIView
    func attach(_ parent: UIView?, _ block: PuyoBlock?) -> Puyo<Holder>
}

extension PuyoAttacher where Self: UIView {
    @discardableResult
    public func attach(_ parent: UIView? = nil, _ block: PuyoBlock? = nil) -> Puyo<Self> {
        let link = Puyo(self)
        block?(self)
        parent?.addSubview(self)
        return link
    }
}

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
