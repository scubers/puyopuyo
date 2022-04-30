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

    public func getParasitableView() -> ViewParasitable? {
        parentContainer?.getParasitableView()
    }

    // MARK: - ViewParasitable

    public func addParasite(_ parasite: UIView) {
        getParasitableView()?.addParasite(parasite)
    }

    public func removeParasite(_ parasite: UIView) {
        getParasitableView()?.removeParasite(parasite)
    }

    public func setNeedsLayout() {
        getParasitableView()?.setNeedsLayout()
    }

    // MARK: - MeasureChildrenDelegate

    public func children(for _: Measure) -> [Measure] {
        layoutChildren.filter { node in
            if let superview = node.getPresentingView()?.superview {
                return superview === getParasitableView()
            }
            return true
        }.map(\.layoutMeasure)
    }

    // MARK: - MeasureDelegate

    public func needsRelayout(for _: Measure) {
        getParasitableView()?.setNeedsLayout()
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
                getParasitableView()?.removeParasite(view)
            } else if let virtualGroup = child as? VirtualGroup {
                virtualGroup._unparasiteChildren()
            }
        }
    }

    private func _parasiteChildren() {
        layoutChildren.forEach { node in
            if case .concrete(let view) = layoutNodeType {
                getParasitableView()?.addParasite(view)
            } else if let virtualGroup = node as? VirtualGroup {
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
