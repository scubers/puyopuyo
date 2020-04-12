//
//  MeasureCaculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

class MeasureCaculator {
    static func caculate(measure: Measure, byParent _: Measure, remain size: CGSize) -> Size {
        if !measure.activated {
            return Size()
        }
        let margin = measure.margin

        let parentCGSize = CGSize(width: max(0, size.width - margin.left - margin.right),
                                  height: max(0, size.height - margin.top - margin.bottom))

        if measure.size.maybeWrap(), parentCGSize.width == 0 || parentCGSize.height == 0 {
            // 若自身尺寸是包裹，并且剩余空间存在0，则不计算
            return Size()
        }

        var widthSize = measure.size.width
        var heightSize = measure.size.height
        
        var maxSize = CGSize(width: min(parentCGSize.width, widthSize.max), height: min(parentCGSize.height, heightSize.max))
        if widthSize.isFixed { maxSize.width = widthSize.fixedValue }
        if heightSize.isFixed { maxSize.height = heightSize.fixedValue }
        
        if measure.size.isWrap() {
            let wrappedSize = measure.py_sizeThatFits(maxSize)
            widthSize = .fix(min(widthSize.getWrapSize(by: wrappedSize.width), maxSize.width))
            heightSize = .fix(min(heightSize.getWrapSize(by: wrappedSize.height), maxSize.height))

        } else if widthSize.isWrap {
            let wrappedCGSize = measure.py_sizeThatFits(maxSize)
            widthSize = .fix(min(widthSize.getWrapSize(by: wrappedCGSize.width), maxSize.width))

        } else if heightSize.isWrap {
            let wrappedCGSize = measure.py_sizeThatFits(maxSize)
            heightSize = .fix(min(heightSize.getWrapSize(by: wrappedCGSize.height), maxSize.height))
        }

        return Size(width: widthSize, height: heightSize)
    }
}
