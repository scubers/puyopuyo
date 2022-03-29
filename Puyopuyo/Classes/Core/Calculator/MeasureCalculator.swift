//
//  MeasureCalculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

class MeasureCalculator: Calculator {
    func calculate(_ measure: Measure, residual: CGSize) -> CGSize {
        if !measure.activated || !measure.size.isCalculable {
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

        if measure.size.bothNotWrap() {
            // 非包裹，可以直接返回预估值
            return CalculateUtil.calculateEstimateSize(for: measure, residual: residual)
        }

        let tempMaxSize = CGSize(
            width: min(parentSize.width, measure.size.width.max),
            height: min(parentSize.height, measure.size.height.max)
        )

        // 后续提供计算的最终可用剩余空间
        let aspectResidual = CalculateUtil.fit(tempMaxSize, aspectRatio: measure.size.aspectRatio, strategy: .collapse)

        var contentSize = measure.sizeThatFits(aspectResidual)
        contentSize.width = Swift.min(contentSize.width, aspectResidual.width)
        contentSize.height = Swift.min(contentSize.height, aspectResidual.height)

        // handl width
        switch measure.size.width.sizeType {
        case .fixed:
            contentSize.width = measure.size.width.fixedValue
        case .ratio:
            contentSize.width = aspectResidual.width
        case .wrap:
            contentSize.width = measure.size.width.getWrapSize(by: contentSize.width)
        case .aspectRatio:
            break
        }

        // handle height
        switch measure.size.height.sizeType {
        case .fixed:
            contentSize.height = measure.size.height.fixedValue
        case .ratio:
            contentSize.height = aspectResidual.height
        case .wrap:
            contentSize.height = measure.size.height.getWrapSize(by: contentSize.height)
        case .aspectRatio:
            break
        }

        let finalSize = CalculateUtil.fit(contentSize, aspectRatio: measure.size.aspectRatio, strategy: .expand)
        return finalSize
    }
}
