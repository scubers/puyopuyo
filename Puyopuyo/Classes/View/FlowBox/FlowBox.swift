//
//  FlowBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/8/20.
//

import Foundation

open class FlowBox: BoxView<FlowRegulator> {
    public convenience init(count: Int) {
        self.init()
        attach().arrangeCount(count)
    }
}

open class HFlow: FlowBox {}

open class VFlow: FlowBox {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        attach().direction(.y)
    }

    public required init?(coder _: NSCoder) {
        fatalError()
    }
}
