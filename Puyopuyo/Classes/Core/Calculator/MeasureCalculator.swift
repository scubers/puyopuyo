//
//  MeasureCalculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

class MeasureCalculator: Calculator {
    func calculate(_ measure: Measure, layoutResidual: CGSize) -> CGSize {
        if !measure.activated || !measure.size.isCalculable {
            return .zero
        }

        if measure.size.bothNotWrap {
            // 非包裹，可以直接返回预估值
            return IntrinsicSizeHelper.getEstimateIntrinsic(for: measure, layoutResidual: layoutResidual)
        }

        // 下面计算逻辑一定包含wrap

        let contentResidual = ResidualHelper.getContentResidual(layoutResidual: layoutResidual, margin: measure.margin, size: measure.size)

        if contentResidual.width == 0 || contentResidual.height == 0 {
            // 若自身尺寸是包裹，并且剩余空间存在0，则不计算
            return .zero
        }

        // 后续提供计算的最终可用剩余空间
        let contentSize = measure.sizeThatFits(contentResidual).clip(by: contentResidual)
        let finalSize = IntrinsicSizeHelper.getIntrinsicSize(from: measure.size, contentResidual: contentResidual, wrappedContent: contentSize)
        return finalSize
    }
}
