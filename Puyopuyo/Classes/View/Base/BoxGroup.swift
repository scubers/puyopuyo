//
//  VirtualGroup.swift
//  Puyopuyo
//
//  Created by J on 2022/4/27.
//

import Foundation

public class BoxGroup: InternalBoxLayoutContainer, MeasureChildrenDelegate, MeasureMetricChangedDelegate, AutoDisposable, ViewParasitizing {
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
        superBox?.willRemoveLayoutNode(self)
        superBox = nil
    }

    public func willRemoveLayoutNode(_ node: BoxLayoutNode) {
        _willRemoveLayoutNode(node)
    }

    public var layoutVisibility: Visibility = .visible {
        didSet {
            guard oldValue != layoutVisibility else { return }
            switch layoutVisibility {
            case .visible:
                superBox?.addParasiteNode(self)
                layoutRegulator.activated = true
            case .invisible:
                superBox?.removeParasiteNode(self)
                layoutRegulator.activated = true
            case .free:
                superBox?.addParasiteNode(self)
                layoutRegulator.activated = false
            case .gone:
                superBox?.removeParasiteNode(self)
                layoutRegulator.activated = false
            }
        }
    }

    public func addLayoutNode(_ node: BoxLayoutNode) {
        _addLayoutNode(node)
    }

    public func didMoveToSuperBox(_ superBox: BoxLayoutContainer) {
        self.superBox = superBox
    }

    // MARK: - ViewParasitable

    public func addParasite(_ parasite: ViewDisplayable) {
        if layoutVisibility == .visible || layoutVisibility == .free {
            superBox?.addParasite(parasite)
        }
    }

    public func removeParasite(_ parasite: ViewDisplayable) {
        superBox?.removeParasite(parasite)
    }

    // MARK: - MeasureChildrenDelegate

    public func children(for _: Measure) -> [Measure] {
        layoutChildren.map(\.layoutMeasure)
    }

    public func measureIsLayoutEntry(_: Measure) -> Bool {
        false
    }

    // MARK: - MeasureDelegate

    public func metricDidChanged(for _: Measure) {
        parasitingHostView?.setNeedsLayout()
    }

    // MARK: - Public

    public func createRegulator() -> Regulator {
        fatalError()
    }

    // MARK: - Private

    private func _generateRegulator() -> Regulator {
        let r = createRegulator()
        r.changeDelegate = self
        r.childrenDelegate = self
        return r
    }
}

// MARK: - Generic group

public class GenericBoxGroup<R: Regulator>: BoxGroup, RegulatorSpecifier {
    // MARK: - RegulatorSpecifier

    public var regulator: R { layoutRegulator as! R }
}
