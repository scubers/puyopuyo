//
//  VirtualGroup.swift
//  Puyopuyo
//
//  Created by J on 2022/4/27.
//

import Foundation

public class BoxGroup: BoxLayoutContainer, MeasureChildrenDelegate, MeasureMetricChangedDelegate, AutoDisposable, ViewParasitizing {
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

    public func addLayoutNode(_ node: BoxLayoutNode) {
        _addLayoutNode(node)
    }

    // MARK: - ViewParasitable

    public func addParasite(_ parasite: ViewDisplayable) {
        if [Visibility.visible, .free].contains(layoutVisibility) {
            superBox?.addParasite(parasite)
        }
    }

    public func removeParasite(_ parasite: ViewDisplayable) {
        superBox?.removeParasite(parasite)
    }

    public func setNeedsLayout() {
        superBox?.setNeedsLayout()
    }

    // MARK: - MeasureChildrenDelegate

    public func children(for _: Measure) -> [Measure] {
        layoutChildren.map(\.layoutMeasure)
    }

    // MARK: - MeasureDelegate

    public func metricDidChanged(for _: Measure) {
        setNeedsLayout()
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
                removeParasite(view)
            } else if let group = child as? BoxGroup {
                group._unparasiteChildren()
            }
        }
    }

    private func _parasiteChildren() {
        layoutChildren.forEach { child in
            if case .concrete(let view) = child.layoutNodeType {
                addParasite(view)
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
