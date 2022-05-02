//
//  FlowGroup.swift
//  Puyopuyo
//
//  Created by ByteDance on 2022/5/2.
//

import Foundation

// MARK: - FlowGroup

public class FlowGroup: GenericVirtualGroup<FlowRegulator> {
    override public func createRegulator() -> FlowRegulator {
        FlowRegulator(delegate: self, sizeDelegate: nil, childrenDelegate: self)
    }
}

public class HFlowGroup: FlowGroup {
    override public init() {
        super.init()
        regulator.direction = .horizontal
    }
}

public class VFlowGroup: FlowGroup {
    override public init() {
        super.init()
        regulator.direction = .vertical
    }
}
