//
//  VirtualGroup.swift
//  Puyopuyo
//
//  Created by J on 2022/4/27.
//

import Foundation

public class VirtualGroup: BoxLayoutContainer, MeasureChildrenDelegate, MeasureDelegate, AutoDisposable {
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

    // MARK: - ViewParasitable

    public func addParasite(_ parasite: ViewDisplayable) {
        parasitizingHost?.addParasite(parasite)
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

    public func needsRelayout(for _: Measure) {
        parasitizingHost?.setNeedsLayout()
    }

    // MARK: - Public

    public func createRegulator() -> Regulator {
        fatalError()
    }

    // MARK: - Private

    private func _generateRegulator() -> Regulator {
        let r = createRegulator().setIsLayoutEntryPoint(false)
        r.delegate = self
        r.childrenDelegate = self
        return r
    }

    private func _unparasiteChildren() {
        layoutChildren.forEach { child in
            if case .concrete(let view) = child.layoutNodeType {
                parasitizingHost?.removeParasite(view)
            } else if let virtualGroup = child as? VirtualGroup {
                virtualGroup._unparasiteChildren()
            }
        }
    }

    private func _parasiteChildren() {
        layoutChildren.forEach { child in
            if case .concrete(let view) = child.layoutNodeType {
                parasitizingHost?.addParasite(view)
            } else if let virtualGroup = child as? VirtualGroup {
                virtualGroup._parasiteChildren()
            }
        }
    }
}

// MARK: - Generic group

public class GenericVirtualGroup<R: Regulator>: VirtualGroup, RegulatorSpecifier {
    // MARK: - RegulatorSpecifier

    public var regulator: R { layoutRegulator as! R }
}

// MARK: - LinearGroup

public class LinearGroup: GenericVirtualGroup<LinearRegulator> {
    override public func createRegulator() -> LinearRegulator {
        LinearRegulator(delegate: self, sizeDelegate: nil, childrenDelegate: self)
    }
}

public class HGroup: LinearGroup {
    override public init() {
        super.init()
        regulator.direction = .x
    }
}

public class VGroup: LinearGroup {
    override public init() {
        super.init()
        regulator.direction = .y
    }
}

// MARK: - FlowGroup

public class FlowGroup: GenericVirtualGroup<FlowRegulator> {
    override public func createRegulator() -> FlowRegulator {
        FlowRegulator(delegate: self, sizeDelegate: nil, childrenDelegate: self)
    }
}

public class HFlowGroup: FlowGroup {
    override public init() {
        super.init()
        regulator.direction = .x
    }
}

public class VFlowGroup: FlowGroup {
    override public init() {
        super.init()
        regulator.direction = .y
    }
}

// MARK: - ZGroup

public class ZGroup: GenericVirtualGroup<ZRegulator> {
    override public func createRegulator() -> ZRegulator {
        ZRegulator(delegate: self, sizeDelegate: nil, childrenDelegate: self)
    }
}
