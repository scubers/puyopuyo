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

// MARK: - UIView

public extension Puyo where T: UIView {
    static func ensureInactivate(_ view: UIView, _ msg: String = "") {
        assert(!view.layoutMeasure.activated, msg)
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

// MARK: - ViewDisplayable

extension Puyo: ViewDisplayable where T: ViewDisplayable {
    public var dislplayView: UIView {
        view.dislplayView
    }
}

// MARK: - ViewParasitable

extension Puyo: ViewParasitable where T: ViewParasitable {
    public func addParasite(_ parasite: UIView) {
        view.addParasite(parasite)
    }

    public func removeParasite(_ parasite: UIView) {
        view.removeParasite(parasite)
    }

    public func setNeedsLayout() {
        view.setNeedsLayout()
    }
}

// MARK: - BoxLayoutNode

extension Puyo: BoxLayoutNode where T: BoxLayoutNode {
    public func getParasitableView() -> ViewParasitable? {
        view.getParasitableView()
    }

    public var parentContainer: BoxLayoutContainer? {
        set { view.parentContainer = newValue }
        get { view.parentContainer }
    }

    public func removeFromContainer() {
        view.removeFromContainer()
    }

    public var layoutMeasure: Measure {
        view.layoutMeasure
    }

    public var layoutNodeType: BoxLayoutNodeType {
        view.layoutNodeType
    }
}

// MARK: - BoxLayoutContainer

extension Puyo: BoxLayoutContainer where T: BoxLayoutContainer {
    public var layoutRegulator: Regulator { view.layoutRegulator }

    /// Do not call setter by your self
    public var layoutChildren: [BoxLayoutNode] {
        get { view.layoutChildren }
        set { view.layoutChildren = newValue }
    }

    public func addLayoutNode(_ node: BoxLayoutNode) {
        view.addLayoutNode(node)
    }

    public func fixChildrenCenterByHostPosition() {
        view.fixChildrenCenterByHostPosition()
    }
}
