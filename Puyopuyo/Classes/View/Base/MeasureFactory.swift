//
//  MeasureBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/23.
//

import Foundation

class MeasureFactory {
    static var measureHoldingKey = "measureHoldingKey"

    static func getMeasure(from view: UIView) -> Measure {
        var measure = objc_getAssociatedObject(view, &MeasureFactory.measureHoldingKey) as? Measure
        if measure == nil {
            if view is FlowBox {
                measure = FlowRegulator(target: view)
            } else if view is ZBox {
                measure = ZRegulator(target: view)
            } else if view is LinearBox {
                measure = LinearRegulator(target: view)
            } else {
                measure = Measure(target: view)
            }
            objc_setAssociatedObject(view, &MeasureFactory.measureHoldingKey, measure, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return measure!
    }
}
