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

    public weak var parentContainer: BoxLayoutContainer?

    public lazy var layoutRegulator: Regulator = _generateRegulator()

    public var layoutChildren: [BoxLayoutNode] = []

    public var layoutMeasure: Measure { layoutRegulator }

    public var layoutNodeType: BoxLayoutNodeType { .virtual }

    public func removeFromContainer() {
        _unparasiteChildren()
        if let index = parentContainer?.layoutChildren.firstIndex(where: { $0 === self }) {
            parentContainer?.layoutChildren.remove(at: index)
        }
    }

    public var parasitizingHost: ViewParasitizing? {
        parentContainer?.parasitizingHost
    }

    public var layoutVisibility: Visibility = .visible {
        didSet {
            guard oldValue != layoutVisibility else { return }
            switch layoutVisibility {
            case .visible:
                _parasiteChildren()
                layoutMeasure.activated = true
            case .invisible:
                _unparasiteChildren()
                layoutMeasure.activated = true
            case .free:
                _parasiteChildren()
                layoutMeasure.activated = false
            case .gone:
                _unparasiteChildren()
                layoutMeasure.activated = false
            }
            setNeedsLayout()
        }
    }

    // MARK: - ViewParasitable

    public func addParasite(_ parasite: ViewDisplayable) {
        if [Visibility.visible, .free].contains(layoutVisibility) {
            parasitizingHost?.addParasite(parasite)
        }
    }

    public func removeParasite(_ parasite: ViewDisplayable) {
        parasitizingHost?.removeParasite(parasite)
    }

    public func setNeedsLayout() {
        parasitizingHost?.setNeedsLayout()
    }

    // MARK: - MeasureChildrenDelegate

    public func children(for _: Measure) -> [Measure] {
        layoutChildren.filter { node in
            if let superview = node.layoutNodeView?.superview {
                return superview === parasitizingHost
            }
            return true
        }.map(\.layoutMeasure)
    }

    // MARK: - MeasureDelegate

    public func metricDidChanged(for _: Measure) {
        parasitizingHost?.setNeedsLayout()
    }

    // MARK: - Public

    public func createRegulator() -> Regulator {
        fatalError()
    }

    // MARK: - Private

    private func _generateRegulator() -> Regulator {
        let r = createRegulator().setIsLayoutEntryPoint(false)
        r.changeDelegate = self
        r.childrenDelegate = self
        return r
    }

    private func _unparasiteChildren() {
        layoutChildren.forEach { child in
            if case .concrete(let view) = child.layoutNodeType {
                parasitizingHost?.removeParasite(view)
            } else if let group = child as? BoxGroup {
                group._unparasiteChildren()
            }
        }
    }

    private func _parasiteChildren() {
        layoutChildren.forEach { child in
            if case .concrete(let view) = child.layoutNodeType {
                parasitizingHost?.addParasite(view)
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