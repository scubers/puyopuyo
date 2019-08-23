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
            
            if measure.size.isWrap() {
                
                let wrappedSize = measure.target?.py_sizeThatFits(CGSize(width: widthSize.max, height: heightSize.max))
                widthSize = .fix(widthSize.getWrapSize(by: wrappedSize?.width ?? 0))
                heightSize = .fix(heightSize.getWrapSize(by: wrappedSize?.height ?? 0))
                
            } else if widthSize.isWrap {
                
                let wrappedCGSize = measure.target?.py_sizeThatFits(CGSize(width: widthSize.max, height: parentCGSize.height))
                widthSize = .fix(widthSize.getWrapSize(by: wrappedCGSize?.width ?? 0))
                
            } else if heightSize.isWrap {
                
                let wrappedCGSize = measure.target?.py_sizeThatFits(CGSize(width: parentCGSize.width, height: heightSize.max))
                heightSize = .fix(heightSize.getWrapSize(by: wrappedCGSize?.height ?? 0))
                
            }
            
            return Size(width: widthSize, height: heightSize)
        default:
            break
        }
        
        return Size()
        
    }
}
