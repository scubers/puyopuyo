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
    func setNeedsLayout()
}

/// Describe a node that can be layout
public protocol BoxLayoutNode: AnyObject {
    var layoutMeasure: Measure { get }
    var presentingView: UIView? { get }
}

///
/// Describe a container that can manage the layout node
public protocol BoxLayoutContainer: BoxLayoutNode, ViewParasitable {
    /// 被子节点寄生的view -> parasiticView.addSubview()
    var hostView: ViewParasitable? { get set }

    var layoutRegulator: Regulator { get }

    var layoutChildren: [BoxLayoutNode] { get }

    func addLayoutNode(_ node: BoxLayoutNode)

    func fixChildrenCenterByHostView()
}

// MARK: - Default impl

public extension BoxLayoutNode {
    var isSelfCoordinate: Bool { presentingView != nil }
}

extension UIView: BoxLayoutNode {
    public var layoutMeasure: Measure { py_measure }
    public var presentingView: UIView? { self }
}
