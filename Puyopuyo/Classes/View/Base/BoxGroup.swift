//
//  VirtualGroup.swift
//  Puyopuyo
//
//  Created by J on 2022/4/27.
//

import Foundation

public class BoxGroup: BoxLayoutContainer, MeasureChildrenDelegate, MeasureMetricChangedDelegate, AutoDisposable {
    public init() {}

    // MARK: - AutoDisposable

    private let bag = NSObject()
    public func addDisposer(_ disposer: Disposer, for key: String?) {
        bag.addDisposer(disposer, for: key)
    }

    // MARK: - BoxLayoutContainer

    public weak var superBox: BoxLayoutContainer?

    public lazy var layoutRegulator: Regulator = _generateRegulator()

    public var layoutChildren: [BoxLayoutNode] = []

    public var layoutMeasure: Measure { layoutRegulator }

    public var layoutNodeType: BoxLayoutNodeType { .virtual }

    public func removeFromSuperBox() {
        _unparasiteChildren()
        if let index = superBox?.layoutChildren.firstIndex(where: { $0 === self }) {
            superBox?.layoutChildren.remove(at: index)
        }
        superBox = nil
    }

    public var parasitizingHostForChildren: ViewParasitizing? {
        superBox?.parasitizingHostForChildren
    }

    public var layoutVisibility: Visibility = .visible {
        didSet {
            guard oldValue != layoutVisibility else { return }
            switch layoutVisibility {
            case .visible:
                _parasiteChildren()
                layoutRegulator.activated = true
            case .invisible:
                _unparasiteChildren()
                layoutRegulator.activated = true
            case .free:
                _parasiteChildren()
                layoutRegulator.activated = false
            case .gone:
                _unparasiteChildren()
                layoutRegulator.activated = false
            }
            setNeedsLayout()
        }
    }

    public func fixChildrenCenterByHostPosition() {
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
    
    public func addLayoutNode(_ node: BoxLayoutNode) {
        _addLayoutNode(node)
    }

    // MARK: - ViewParasitable

    public func addParasite(_ parasite: ViewDisplayable) {
        if [Visibility.visible, .free].contains(layoutVisibility) {
            parasitizingHostForChildren?.addParasite(parasite)
        }
    }

    public func removeParasite(_ parasite: ViewDisplayable) {
        parasitizingHostForChildren?.removeParasite(parasite)
    }

    public func setNeedsLayout() {
        parasitizingHostForChildren?.setNeedsLayout()
    }

    // MARK: - MeasureChildrenDelegate

    public func children(for _: Measure) -> [Measure] {
        layoutChildren.filter { node in
            if let superview = node.layoutNodeView?.superview {
                return superview === parasitizingHostForChildren
            }
            return true
        }.map(\.layoutMeasure)
    }

    // MARK: - MeasureDelegate

    public func metricDidChanged(for _: Measure) {
        parasitizingHostForChildren?.setNeedsLayout()
    }

    // MARK: - Public

    public func createRegulator() -> Regulator {
        fatalError()
    }

    // MARK: - Private

    private func _generateRegulator() -> Regulator {
        let r = createRegulator()
        r.isLayoutEntryPoint = false
        r.changeDelegate = self
        r.childrenDelegate = self
        return r
    }

    private func _unparasiteChildren() {
        layoutChildren.forEach { child in
            if case .concrete(let view) = child.layoutNodeType {
                parasitizingHostForChildren?.removeParasite(view)
            } else if let group = child as? BoxGroup {
                group._unparasiteChildren()
            }
        }
    }

    private func _parasiteChildren() {
        layoutChildren.forEach { child in
            if case .concrete(let view) = child.layoutNodeType {
                parasitizingHostForChildren?.addParasite(view)
            } else if let group = child as? BoxGroup {
                group._parasiteChildren()
            }
        }
    }
}

// MARK: - Generic group

public class GenericBoxGroup<R: Regulator>: BoxGroup, RegulatorSpecifier {
    // MARK: - RegulatorSpecifier

    public var regulator: R { layoutRegulator as! R }
}
