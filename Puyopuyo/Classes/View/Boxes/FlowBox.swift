//
//  FlowBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/8/20.
//

import Foundation

open class FlowBox: GenericBoxView<FlowRegulator> {
    public convenience init(count: Int = 0) {
        self.init()
        attach().arrangeCount(count)
    }

    override public func createRegulator() -> FlowRegulator {
        FlowRegulator(delegate: self, sizeDelegate: self, childrenDelegate: self)
    }
}

open class HFlow: FlowBox {
    override public func createRegulator() -> FlowRegulator {
        let reg = super.createRegulator()
        reg.direction = .horizontal
        return reg
    }
}

open class VFlow: FlowBox {
    override public func createRegulator() -> FlowRegulator {
        let reg = super.createRegulator()
        reg.direction = .vertical
        return reg
    }
}
