//
//  BoxHelper.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/9.
//

import UIKit

/// Describe an object that can be add view to it
public protocol ViewParasitable: AnyObject {
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
    var layoutMeasure: Measure { get }
    var layoutNodeType: BoxLayoutNodeType { get }
    var parentContainer: BoxLayoutContainer? { get set }
    func removeFromContainer()
    func getParasitableView() -> ViewParasitable?
}

///
/// Describe a container that can manage the layout node
public protocol BoxLayoutContainer: BoxLayoutNode, ViewParasitable {
    var layoutRegulator: Regulator { get }

    /// Do not call setter by your self
    var layoutChildren: [BoxLayoutNode] { get set }

    func addLayoutNode(_ node: BoxLayoutNode)

    func fixChildrenCenterByHostView()
}

// MARK: - Default impl

public extension BoxLayoutNode {
    func getPresentingView() -> UIView? {
        switch layoutNodeType {
        case .concrete(let v): return v
        default: return nil
        }
    }
}

public extension BoxLayoutContainer {
    func addLayoutNode(_ node: BoxLayoutNode) {
        // set parent first
        node.parentContainer = self
        // add child second
        layoutChildren.append(node)

        if let view = node.getPresentingView() {
            addParasite(view)
        }
    }

    func fixChildrenCenterByHostView() {
        guard layoutNodeType.isVirtual else {
            return
        }

        let center = layoutRegulator.calculatedCenter
        let size = layoutRegulator.calculatedSize

        // 计算虚拟位置的偏移量
        let delta = CGPoint(x: center.x - size.width / 2, y: center.y - size.height / 2)

        layoutChildren.forEach { node in
            var center = node.layoutMeasure.calculatedCenter
            center.x += delta.x
            center.y += delta.y
            node.layoutMeasure.calculatedCenter = center

            if let node = node as? BoxLayoutContainer, node.layoutNodeType.isVirtual {
                node.fixChildrenCenterByHostView()
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

    public var layoutMeasure: Measure { py_measure }

    public var layoutNodeType: BoxLayoutNodeType {
        .concrete(self)
    }

    public func removeFromContainer() {
        removeFromSuperview()
    }

    public func getParasitableView() -> ViewParasitable? {
        if let container = self as? BoxLayoutContainer {
            return container
        }
        return parentContainer?.getParasitableView()
    }
}
