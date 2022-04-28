//
//  VirtualGroup.swift
//  Puyopuyo
//
//  Created by J on 2022/4/27.
//

import Foundation

public class VirtualGroup<R: Regulator>: BoxLayoutContainer, RegulatorSpecifier, MeasureChildrenDelegate, MeasureDelegate, AutoDisposable {
    public init() {}

    // MARK: - AutoDisposable

    private let bag = NSObject()
    public func addDisposer(_ disposer: Disposer, for key: String?) {
        bag.addDisposer(disposer, for: key)
    }

    // MARK: - RegulatorSpecifier

    public var regulator: R { layoutRegulator as! R }

    // MARK: - BoxLayoutContainer

    public weak var parentContainer: BoxLayoutContainer?

    public lazy var layoutRegulator: Regulator = createRegulator()

    public var layoutChildren: [BoxLayoutNode] = []

    public var layoutMeasure: Measure { layoutRegulator }

    public var layoutNodeType: BoxLayoutNodeType { .virtual }

    public func removeFromContainer() {
        layoutChildren.forEach { node in
            node.removeFromContainer()
        }
        parentContainer?.layoutChildren.removeAll(where: { $0 === self })
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

    public func createRegulator() -> R {
        fatalError()
    }
}

// MARK: - LinearGroup

public class LinearGroup: VirtualGroup<LinearRegulator> {
    class Regulator: LinearRegulator {
        override func createCalculator() -> Calculator {
            LinearCalculator(calculateChildrenImmediately: true)
        }
    }

    override public func createRegulator() -> VirtualGroup<LinearRegulator>.RegulatorType {
        Regulator(delegate: self, sizeDelegate: nil, childrenDelegate: self)
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

public class FlowGroup: VirtualGroup<FlowRegulator> {
    class Regulator: FlowRegulator {
        override func createCalculator() -> Calculator {
            FlowCalculator(calculateChildrenImmediately: true)
        }
    }

    override public func createRegulator() -> FlowRegulator {
        Regulator(delegate: self, sizeDelegate: nil, childrenDelegate: self)
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

public class ZGroup: VirtualGroup<ZRegulator> {
    class Regulator: ZRegulator {
        override func createCalculator() -> Calculator {
            ZCalculator(calculateChildrenImmediately: true)
        }
    }

    override public func createRegulator() -> ZRegulator {
        Regulator(delegate: self, sizeDelegate: nil, childrenDelegate: self)
    }
}
