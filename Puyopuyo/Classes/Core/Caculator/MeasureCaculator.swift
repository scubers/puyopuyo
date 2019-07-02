//
//  MeasureCaculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

class MeasureCaculator {
    static func caculate(measure: Measure, byParent parent: Measure) -> Size {
        if !measure.activated {
            return Size()
        }
        
        switch parent {
        case is FlatLayout: fallthrough
        case is ZLayout:
            let parentCGSize = parent.target?.py_size ?? .zero
            
            var widthSize = measure.size.width
            var heightSize = measure.size.height
            
            if widthSize.isWrap {
                let wrappedCGSize = measure.target?.py_sizeThatFits(CGSize(width: 0, height: parentCGSize.height))
                widthSize = .fixed(widthSize.getWrapSize(by: wrappedCGSize?.width ?? 0))
            }
            
            if heightSize.isWrap {
                let wrappedCGSize = measure.target?.py_sizeThatFits(CGSize(width: 0, height: parentCGSize.height))
                heightSize = .fixed(heightSize.getWrapSize(by: wrappedCGSize?.height ?? 0))
            }
            
            return Size(width: widthSize, height: heightSize)
        default:
            break
        }
        
        return Size()
        
    }
}
