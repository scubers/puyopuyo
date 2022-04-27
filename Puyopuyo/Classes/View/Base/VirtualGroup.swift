//
//  VirtualGroup.swift
//  Puyopuyo
//
//  Created by J on 2022/4/27.
//

import Foundation

public class VirtualGroup<R: Regulator>: BoxLayoutContainer, MeasureChildrenDelegate, MeasureDelegate, RegulatorSpecifier, AutoDisposable {
    public init() {}
    private let bag = NSObject()
    public func addDisposer(_ disposer: Disposer, for key: String?) {
        bag.addDisposer(disposer, for: key)
    }

    public var regulator: R { layoutRegulator as! R }

    public weak var hostView: ViewParasitable?

    public lazy var layoutRegulator: Regulator = createRegulator()

    public func addLayoutNode(_ node: BoxLayoutNode) {
        guard let hostView = hostView else {
            fatalError()
        }

        layoutChildren.append(node)
        if let view = node.presentingView {
            hostView.addParasite(view)
        }
    }

    public var layoutChildren: [BoxLayoutNode] = []

    public var layoutMeasure: Measure { layoutRegulator }

    public var presentingView: UIView? { nil }

    public func fixChildrenCenterByHostView() {
        let center = layoutRegulator.calculatedCenter
        let size = layoutRegulator.calculatedSize

        // 计算虚拟位置的偏移量
        let delta = CGPoint(x: center.x - size.width / 2, y: center.y - size.height / 2)

        layoutChildren.forEach { node in
            var center = node.layoutMeasure.calculatedCenter
            center.x += delta.x
            center.y += delta.y
            node.layoutMeasure.calculatedCenter = center

            if let node = node as? BoxLayoutContainer, !node.isSelfCoordinate {
                node.fixChildrenCenterByHostView()
            }
        }
    }

    public func addParasite(_ parasite: UIView) {
        hostView?.addParasite(parasite)
    }

    public func setNeedsLayout() {
        hostView?.setNeedsLayout()
    }

    public func children(for _: Measure) -> [Measure] {
        layoutChildren.filter { node in
            if let presentingView = node.presentingView {
                return presentingView.superview === hostView
            }
            return true
        }.map(\.layoutMeasure)
    }

    public func needsRelayout(for _: Measure) {
        hostView?.setNeedsLayout()
    }

    public func createRegulator() -> R {
        fatalError()
    }
}

public class LinearGroup: VirtualGroup<LinearRegulator> {
    class Regulator: LinearRegulator {
        override func createCalculator() -> Calculator {
            LinearCalculator(estimateChildren: false)
        }
    }

    override public func createRegulator() -> VirtualGroup<LinearRegulator>.RegulatorType {
        Regulator(delegate: self, sizeDelegate: nil, childrenDelegate: self)
    }
}

public class FlowGroup: VirtualGroup<FlowRegulator> {
    override public func createRegulator() -> VirtualGroup<FlowRegulator>.RegulatorType {
        FlowRegulator(delegate: self, sizeDelegate: nil, childrenDelegate: self)
    }
}
