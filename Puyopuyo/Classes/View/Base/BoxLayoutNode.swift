//
//  BoxHelper.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/9.
//

import UIKit

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
    var superBox: BoxLayoutContainer? { get }

    var layoutVisibility: Visibility { get set }

    func removeFromSuperBox()

    func didMoveToSuperBox(_ superBox: BoxLayoutContainer)
}

///
/// Describe a container that can manage the layout node
public protocol BoxLayoutContainer: BoxLayoutNode, ViewParasitizing {
    /// Do not call setter by your self
    var layoutChildren: [BoxLayoutNode] { get }

    func addLayoutNode(_ node: BoxLayoutNode)

    func willRemoveLayoutNode(_ node: BoxLayoutNode)
}

// MARK: - BoxLayoutNode extension

public extension BoxLayoutNode {
    var layoutNodeView: UIView? {
        if case .concrete(let v) = layoutNodeType {
            return v
        }
        return nil
    }

    var parasitingHostView: (ViewParasitizing & UIView)? {
        if let view = superBox?.layoutNodeView as? (ViewParasitizing & UIView) {
            return view
        }
        return superBox?.parasitingHostView
    }
}

// MARK: - BoxLayoutContainer extension

internal protocol InternalBoxLayoutContainer: BoxLayoutContainer {
    var layoutChildren: [BoxLayoutNode] { get set }
}

extension InternalBoxLayoutContainer {
    func _addLayoutNode(_ node: BoxLayoutNode) {
        node.removeFromSuperBox()
        layoutChildren.append(node)
        addParasiteNode(node)
        node.didMoveToSuperBox(self)
    }

    func _willRemoveLayoutNode(_ node: BoxLayoutNode) {
        if let index = layoutChildren.firstIndex(where: { $0 === node }) {
            layoutChildren.remove(at: index)
            removeParasiteNode(node)
        }
    }
}

// MARK: - Implementation

extension UIView: BoxLayoutNode {
    private class BoxLayoutMetrics {
        weak var superbox: BoxLayoutContainer?
        var measure: Measure!
        static var associateObjectKey = "py_boxLayoutMetricsKey"
    }

    private var _layoutMetrics: BoxLayoutMetrics {
        get {
            if let m = objc_getAssociatedObject(self, &BoxLayoutMetrics.associateObjectKey) as? BoxLayoutMetrics {
                return m
            }
            let m = BoxLayoutMetrics()
            self._layoutMetrics = m
            return m
        }
        set {
            objc_setAssociatedObject(self, &BoxLayoutMetrics.associateObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public var superBox: BoxLayoutContainer? {
        get { _layoutMetrics.superbox }
        set { _layoutMetrics.superbox = newValue }
    }

    public var layoutMeasure: Measure {
        get {
            if let m = _layoutMetrics.measure {
                return m
            }
            var measure: Measure
            if let regulatable = self as? BoxView {
                measure = regulatable.createRegulator()
            } else {
                measure = Measure(delegate: self, sizeDelegate: self, childrenDelegate: nil)
            }
            _layoutMetrics.measure = measure
            return measure
        }
        set { _layoutMetrics.measure = newValue }
    }

    public var layoutNodeType: BoxLayoutNodeType { .concrete(self) }

    public var layoutVisibility: Visibility {
        set {
            // hidden
            switch newValue {
            case .visible, .free: isHidden = false
            default: isHidden = true
            }
            // activated
            switch newValue {
            case .visible, .invisible: layoutMeasure.activated = true
            default: layoutMeasure.activated = false
            }
        }
        get {
            switch (layoutMeasure.activated, isHidden) {
            case (true, false): return .visible
            case (true, true): return .invisible
            case (false, true): return .gone
            case (false, false): return .free
            }
        }
    }

    public func removeFromSuperBox() {
        superBox?.willRemoveLayoutNode(self)
        superBox = nil
    }

    public func didMoveToSuperBox(_ superBox: BoxLayoutContainer) {
        self.superBox = superBox
    }
}

extension ViewParasitizing {
    func addParasiteNode(_ node: BoxLayoutNode) {
        if let view = node.layoutNodeView {
            addParasite(view)
        } else if let container = node as? BoxLayoutContainer {
            container.layoutChildren.forEach(addParasiteNode(_:))
        }
    }

    func removeParasiteNode(_ node: BoxLayoutNode) {
        if let view = node.layoutNodeView {
            removeParasite(view)
        } else if let container = node as? BoxLayoutContainer {
            container.layoutChildren.forEach(removeParasiteNode(_:))
        }
    }
}
