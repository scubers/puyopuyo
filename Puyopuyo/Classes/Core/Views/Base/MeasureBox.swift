//
//  MeasureBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/23.
//

import Foundation

class MeasureBox {
    
    static var measureHoldingKey = "measureHoldingKey"
    
    static func getMeasure(from: UIView) -> Measure {
        var measure = objc_getAssociatedObject(from, &MeasureBox.measureHoldingKey) as? Measure
        if measure == nil {
            if from is FlatBox {
                measure = FlatLayout(target: from)
            } else if from is ZBox {
                measure = ZLayout(target: from)
            } else if from is FlowBox {
                measure = FlowLayout(target: from)
            } else {
                measure = Measure(target: from)
            }
            objc_setAssociatedObject(from, &MeasureBox.measureHoldingKey, measure, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return measure!
    }    
}
