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

        let maxW = min(parentCGSize.width, widthSize.max)
        let maxH = min(parentCGSize.height, heightSize.max)

        if measure.size.isWrap() {
            let wrappedSize = measure.py_sizeThatFits(CGSize(width: min(widthSize.max, parentCGSize.width), height: min(heightSize.max, parentCGSize.height)))
            widthSize = .fix(min(widthSize.getWrapSize(by: wrappedSize.width), maxW))
            heightSize = .fix(min(heightSize.getWrapSize(by: wrappedSize.height), maxH))

        } else if widthSize.isWrap {
            let wrappedCGSize = measure.py_sizeThatFits(CGSize(width: min(widthSize.max, parentCGSize.width), height: parentCGSize.height))
            widthSize = .fix(min(widthSize.getWrapSize(by: wrappedCGSize.width), maxW))

        } else if heightSize.isWrap {
            let wrappedCGSize = measure.py_sizeThatFits(CGSize(width: parentCGSize.width, height: min(heightSize.max, parentCGSize.height)))
            heightSize = .fix(min(heightSize.getWrapSize(by: wrappedCGSize.height), maxH))
        }

        return Size(width: widthSize, height: heightSize)
    }
}
