//
//  FlowBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/8/20.
//

import Foundation

open class FlowBox: BoxView<FlowRegulator> {
    public convenience init(count: Int = 0) {
        self.init()
        attach().arrangeCount(count)
    }

    override public func createRegulator() -> Regulator {
        FlowRegulator(delegate: self, sizeDelegate: self, childrenDelegate: self)
    }
}

open class HFlow: FlowBox {}

open class VFlow: FlowBox {
    override public init(frame: CGRect) {
        super.init(frame: frame)
        attach().direction(.y)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError()
    }
}
