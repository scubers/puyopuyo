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
            } else if view is FlatBox {
                measure = FlatRegulator(target: view)
            } else {
                measure = Measure(target: view)
            }
            objc_setAssociatedObject(view, &MeasureFactory.measureHoldingKey, measure, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return measure!
    }

    private static var placeholders = Set<Measure>()
    static func getPlaceholder() -> Measure {
        if placeholders.isEmpty {
            return Measure()
        }
        return placeholders.removeFirst()
    }

    static func recyclePlaceholders(_ measures: [Measure]) {
//        placeholders.append(contentsOf: measures)
        measures.forEach({ placeholders.insert($0) })
    }
}
