//
//  FlowGroup.swift
//  Puyopuyo
//
//  Created by J on 2022/5/2.
//

import Foundation

// MARK: - FlowGroup

public class FlowGroup: GenericBoxGroup<FlowRegulator> {
    override public func createRegulator() -> FlowRegulator {
        FlowRegulator(delegate: self, sizeDelegate: nil, childrenDelegate: self)
    }
}

public class HFlowGroup: FlowGroup {
    override public func createRegulator() -> FlowRegulator {
        let reg = super.createRegulator()
        reg.direction = .horizontal
        return reg
    }
}

public class VFlowGroup: FlowGroup {
    override public func createRegulator() -> FlowRegulator {
        let reg = super.createRegulator()
        reg.direction = .vertical
        return reg
    }
}
