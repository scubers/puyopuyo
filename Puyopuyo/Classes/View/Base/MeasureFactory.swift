//
//  MeasureBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/23.
//

import Foundation

// private enum MeasureFactory {
//    static var measureHoldingKey = "measureHoldingKey"
//
//    static func getMeasure(from view: UIView) -> Measure {
//        var measure = objc_getAssociatedObject(view, &MeasureFactory.measureHoldingKey) as? Measure
//        if measure == nil {
//            if view is FlowBox {
//                measure = FlowRegulator(delegate: view)
//            } else if view is ZBox {
//                measure = ZRegulator(delegate: view)
//            } else if view is LinearBox {
//                measure = LinearRegulator(delegate: view)
//            } else {
//                measure = Measure(delegate: view)
//            }
//            objc_setAssociatedObject(view, &MeasureFactory.measureHoldingKey, measure, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//        return measure!
//    }
// }
