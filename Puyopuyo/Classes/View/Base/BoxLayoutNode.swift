//
//  BoxHelper.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/9.
//

import UIKit

public protocol ViewDisplayable: AnyObject {
    var dislplayView: UIView { get }
}

/// Describe an object that can be add view to it
public protocol ViewParasitizing: AnyObject {
    func addParasite(_ parasite: UIView)
    func removeParasite(_ parasite: UIView)
    func setNeedsLayout()
}

public enum BoxLayoutNodeType {
    case virtual
    case concrete(UIView)
    public var isVirtual: Bool {
        switch self {
        case .virtual:
            return true
        case .concrete:
            return false
        }
    }
}

/// Describe a node that can be layout
public protocol BoxLayoutNode: AnyObject {
    /// Layout metrics
    var layoutMeasure: Measure { get }
    /// Node type
    var layoutNodeType: BoxLayoutNodeType { get }
    /// Ref to node's container
    var parentContainer: BoxLayoutContainer? { get set }
    /// Concrete view's superview
    var parasitizingHost: ViewParasitizing? { get }

    func removeFromContainer()
}

///
/// Describe a container that can manage the layout node
public protocol BoxLayoutContainer: BoxLayoutNode, ViewParasitizing {
    var layoutRegulator: Regulator { get }

    /// Do not call setter by your self
    var layoutChildren: [BoxLayoutNode] { get set }
}

// MARK: - Default impl

public extension BoxLayoutNode {
    var layoutNodeView: UIView? {
        if case .concrete(let v) = layoutNodeType {
            return v
        }
        return nil
    }
}

public extension BoxLayoutContainer {
    func addLayoutNode(_ node: BoxLayoutNode) {
        // set parent first
        node.parentContainer = self
        // add child second
        layoutChildren.append(node)

        if let view = node.layoutNodeView {
            addParasite(view)
        }
    }

    func fixChildrenCenterByHostPosition() {
        guard layoutNodeType.isVirtual else {
            return
        }

        let center = layoutRegulator.calculatedCenter
        let size = layoutRegulator.calculatedSize

        // 计算虚拟位置的偏移量
        let delta = CGPoint(x: center.x - size.width / 2, y: center.y - size.height / 2)

        layoutChildren.forEach { child in
            var center = child.layoutMeasure.calculatedCenter
            center.x += delta.x
            center.y += delta.y
            child.layoutMeasure.calculatedCenter = center
            if let node = child as? BoxLayoutContainer {
                node.fixChildrenCenterByHostPosition()
            }
        }
    }
}

extension UIView: BoxLayoutNode {
    private static var parentContainerKey = "parentContainerKey"
    private class Weak {
        init(_ value: AnyObject?) {
            self.value = value
        }

        weak var value: AnyObject?
    }

    public var parentContainer: BoxLayoutContainer? {
        get {
            (objc_getAssociatedObject(self, &UIView.parentContainerKey) as? Weak)?.value as? BoxLayoutContainer
        }
        set {
            objc_setAssociatedObject(self, &UIView.parentContainerKey, Weak(newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private static var measureHoldingKey = "measureHoldingKey"
    public var layoutMeasure: Measure {
        var measure = objc_getAssociatedObject(self, &UIView.measureHoldingKey) as? Measure
        if measure == nil {
            if let regulatable = self as? BoxView {
                measure = regulatable.createRegulator()
            } else {
                measure = Measure(delegate: self, sizeDelegate: self, childrenDelegate: nil)
            }
            objc_setAssociatedObject(self, &UIView.measureHoldingKey, measure, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return measure!
    }

    public var layoutNodeType: BoxLayoutNodeType { .concrete(self) }

    public func removeFromContainer() {
        removeFromSuperview()
        if let index = parentContainer?.layoutChildren.firstIndex(where: { $0 === self }) {
            parentContainer?.layoutChildren.remove(at: index)
        }
    }

    public var parasitizingHost: ViewParasitizing? {
        if let container = self as? BoxLayoutContainer {
            return container
        }
        return parentContainer?.parasitizingHost
    }
}

extension UIView: ViewDisplayable {
    public var dislplayView: UIView { self }
}

extension UIViewController: ViewDisplayable {
    public var dislplayView: UIView { view }
}
