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
        
//        switch parent {
//        case is FlatRegulator: fallthrough
//        case is ZRegulator:
            let parentCGSize = parent.py_size
            
            var widthSize = measure.size.width
            var heightSize = measure.size.height
            
            if measure.size.isWrap() {
                
                let wrappedSize = measure.py_sizeThatFits(CGSize(width: widthSize.max, height: heightSize.max))
                widthSize = .fix(widthSize.getWrapSize(by: wrappedSize.width))
                heightSize = .fix(heightSize.getWrapSize(by: wrappedSize.height))
                
            } else if widthSize.isWrap {
                
                let wrappedCGSize = measure.py_sizeThatFits(CGSize(width: widthSize.max, height: parentCGSize.height))
                widthSize = .fix(widthSize.getWrapSize(by: wrappedCGSize.width))
                
            } else if heightSize.isWrap {
                
                let wrappedCGSize = measure.py_sizeThatFits(CGSize(width: parentCGSize.width, height: heightSize.max))
                heightSize = .fix(heightSize.getWrapSize(by: wrappedCGSize.height))
                
            }
            
            return Size(width: widthSize, height: heightSize)
//        default:
//            break
//        }
//        
//        return Size()
        
    }
}
