//
//  MeasureCalculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

class MeasureCalculator {
    static func calculate(measure: Measure, residual: CGSize) -> CGSize {
        if !measure.activated {
            return .zero
        }
        let margin = measure.margin

        let parentCGSize = CGSize(width: max(0, residual.width - margin.left - margin.right),
                                  height: max(0, residual.height - margin.top - margin.bottom))

        if measure.size.maybeWrap(), parentCGSize.width == 0 || parentCGSize.height == 0 {
            // 若自身尺寸是包裹，并且剩余空间存在0，则不计算
            return .zero
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

        let size = Size(width: widthSize, height: heightSize)
        return Calculator.getIntrinsicSize(margin: measure.margin, residual: residual, size: size)
    }
}
