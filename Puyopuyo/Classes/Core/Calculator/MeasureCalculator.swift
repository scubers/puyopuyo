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

        if measure.size.bothNotWrap() {
            // 非包裹，可以直接返回预估值
            return CalculateUtil.calculateEstimateSize(for: measure, residual: layoutResidual)
        }

        // 下面计算逻辑一定包含wrap

        let contentResidual = _CalculateUtil.getContentResidual(layoutResidual: layoutResidual, margin: measure.margin, contentAspectRatio: measure.size.aspectRatio)

        if contentResidual.width == 0 || contentResidual.height == 0 {
            // 若自身尺寸是包裹，并且剩余空间存在0，则不计算
            return .zero
        }

        // 后续提供计算的最终可用剩余空间

        var contentSize = measure.sizeThatFits(contentResidual)

        // handl width
        switch measure.size.width.sizeType {
        case .fixed:
            contentSize.width = measure.size.width.fixedValue
        case .ratio:
            contentSize.width = contentResidual.width
        case .wrap:
            contentSize.width = min(measure.size.width.getWrapSize(by: contentSize.width), contentResidual.width)
        case .aspectRatio:
            break
        }

        // handle height
        switch measure.size.height.sizeType {
        case .fixed:
            contentSize.height = measure.size.height.fixedValue
        case .ratio:
            contentSize.height = contentResidual.height
        case .wrap:
            contentSize.height = min(measure.size.height.getWrapSize(by: contentSize.height), contentResidual.height)
        case .aspectRatio:
            break
        }

//        let finalSize = CalculateUtil.fit(contentSize, aspectRatio: measure.size.aspectRatio, strategy: .expand)
        let finalSize = contentSize.expand(to: measure.size.aspectRatio)
        return finalSize
    }
}
