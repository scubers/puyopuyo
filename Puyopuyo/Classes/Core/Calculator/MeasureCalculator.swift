//
//  MeasureCalculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

class MeasureCalculator: Calculator {
    func calculate(_ measure: Measure, residual: CGSize) -> CGSize {
        if !measure.activated {
            return .zero
        }
        let margin = measure.margin

        let parentSize = CGSize(
            width: max(0, residual.width - margin.getHorzTotal()),
            height: max(0, residual.height - margin.getVertTotal())
        )

        if measure.size.maybeWrap(), parentSize.width == 0 || parentSize.height == 0 {
            // 若自身尺寸是包裹，并且剩余空间存在0，则不计算
            return .zero
        }

        var widthSize = measure.size.width
        var heightSize = measure.size.height

        var maxSize = CGSize(width: min(parentSize.width, widthSize.max), height: min(parentSize.height, heightSize.max))
        if widthSize.isFixed { maxSize.width = widthSize.fixedValue }
        if heightSize.isFixed { maxSize.height = heightSize.fixedValue }

        if measure.size.isWrap() {
            let wrappedSize = measure.sizeThatFits(maxSize)
            widthSize = .fix(min(widthSize.getWrapSize(by: wrappedSize.width), maxSize.width))
            heightSize = .fix(min(heightSize.getWrapSize(by: wrappedSize.height), maxSize.height))

        } else if widthSize.isWrap {
            let wrappedCGSize = measure.sizeThatFits(maxSize)
            widthSize = .fix(min(widthSize.getWrapSize(by: wrappedCGSize.width), maxSize.width))

        } else if heightSize.isWrap {
            let wrappedCGSize = measure.sizeThatFits(maxSize)
            heightSize = .fix(min(heightSize.getWrapSize(by: wrappedCGSize.height), maxSize.height))
        }

        // TODO: 处理aspectRatio
        let size = Size(width: widthSize, height: heightSize)
        return CalculateUtil.getIntrinsicSize(margin: measure.margin, residual: residual, size: size)
    }
}
