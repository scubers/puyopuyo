//
//  FlowBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/8/20.
//

import Foundation

open class FlowBox: FlatBox {
    public override var regulator: FlowRegulator {
        return py_measure as! FlowRegulator
    }
    
    public convenience init(count: Int) {
        self.init()
        regulator.arrange = count
    }
}

open class HFlow: FlowBox {
    
}
open class VFlow: FlowBox {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        regulator.direction = .y
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
