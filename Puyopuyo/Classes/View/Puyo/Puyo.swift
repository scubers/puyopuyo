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

// MARK: - AutoDisposable

public extension Puyo where T: AutoDisposable {
    /// Accept an outputing as a trigger, do actions
    /// - Parameters:
    ///   - state: state description
    ///   - action: action description
    @discardableResult
    func doOn<O: Outputing, R>(_ state: O, _ action: @escaping (T, R) -> Void) -> Self where O.OutputType == R {
        state.safeBind(to: view, action)
        return self
    }
}

public extension Puyo where T: UIView {
    static func ensureInactivate(_ view: UIView, _ msg: String = "") {
        assert(!view.py_measure.activated, msg)
    }

    enum UpdateStrategy {
        /// Call setNeedsRelayout after action
        case all
        /// Call setNeedsRelayout after action if view's size maybe wrap
        case maybeWrap
    }

    /// Accept an Outputing as a trigger, call [view.py_setNeedsRelayout] after action
    /// - Parameters:
    ///   - state: state description
    ///   - action: action description
    @discardableResult
    func viewUpdate<O: Outputing, R>(on state: O, strategy: UpdateStrategy = .all, _ action: @escaping (T, R) -> Void) -> Self where O.OutputType == R {
        doOn(state) { v, r in
            action(v, r)
            switch strategy {
            case .all:
                v.py_setNeedsRelayout()
            case .maybeWrap:
                v.py_setNeedsLayoutIfMayBeWrap()
            }
        }
    }

    @discardableResult
    func viewUpdate<O: Outputing, R, Object: AnyObject>(on state: O, to object: Object?, strategy: UpdateStrategy = .all, _ action: @escaping (Object, T, R) -> Void) -> Self where O.OutputType == R {
        doOn(state) { [weak object] v, r in
            guard let object = object else {
                return
            }

            action(object, v, r)
            switch strategy {
            case .all:
                v.py_setNeedsRelayout()
            case .maybeWrap:
                v.py_setNeedsLayoutIfMayBeWrap()
            }
        }
    }
}

public protocol ViewDisplayable: BoxLayoutNode {
    var dislplayView: UIView { get }
}

public extension ViewDisplayable where Self: UIView {
    var dislplayView: UIView { self }
    @discardableResult
    func attach(_ parent: ViewDisplayable, _ block: (Self) -> Void = { _ in }) -> Puyo<Self> {
        parent.dislplayView.addSubview(dislplayView)
        block(self)
        return Puyo(self)
    }
}

extension Puyo: BoxLayoutNode where T: BoxLayoutNode {
    public var layoutMeasure: Measure {
        view.layoutMeasure
    }

    public var presentingView: UIView? {
        view.presentingView
    }
}

extension Puyo: ViewDisplayable where T: ViewDisplayable {
    public var dislplayView: UIView {
        view.dislplayView
    }
}

extension UIView: ViewDisplayable {}
//
// extension UIView: ViewDisplayable {
//    public var dislplayView: UIView { self }
// }
//
// extension UIViewController: ViewDisplayable {
//    public var dislplayView: UIView { view }
// }
//
// public extension ViewDisplayable {
//    @discardableResult
//    func attach(_ parent: ViewDisplayable? = nil, _ block: (Self) -> Void = { _ in }) -> Puyo<Self> {
//        let link = Puyo(self)
//        block(self)
//        parent?.dislplayView.addSubview(dislplayView)
//        return link
//    }
// }
//
// extension Puyo: ViewDisplayable where T: ViewDisplayable {
//    public var dislplayView: UIView {
//        view.dislplayView
//    }
// }

// MARK: - BoxLayoutNode attaching

public extension BoxLayoutNode {
    @discardableResult
    func attach(_ parent: BoxLayoutContainer? = nil, _ block: (Self) -> Void = { _ in }) -> Puyo<Self> {
        parent?.addLayoutNode(self)
        block(self)
        return Puyo(self)
    }

    @discardableResult
    func attach(_ parent: ViewParasitable? = nil, _ block: (Self) -> Void = { _ in }) -> Puyo<Self> {
        if let view = presentingView {
            parent?.addParasite(view)
        }
        block(self)
        return Puyo(self)
    }
}

public extension BoxLayoutContainer {
    @discardableResult
    func attach(_ parent: BoxLayoutContainer? = nil, _ block: (Self) -> Void = { _ in }) -> Puyo<Self> {
        if !isSelfCoordinate {
            assert(parent != nil, "Virtual group should not be the root container!!!")
        }
        if !isSelfCoordinate {
            hostView = parent?.hostView
        }
        parent?.addLayoutNode(self)
        block(self)
        return Puyo(self)
    }
}
