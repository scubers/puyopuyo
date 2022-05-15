//
//  IntrinsicSizeHelper.swift
//  Puyopuyo
//
//  Created by J on 2022/5/15.
//

import Foundation

enum IntrinsicSizeHelper {
    static func getIntrinsic(from sizeDesc: SizeDescription, contentResidual: CGFloat, wrappedContent: CGFloat?) -> CGFloat {
        guard contentResidual > 0 else {
            return 0
        }
        switch sizeDesc.sizeType {
        case .fixed:
            return Swift.max(0, sizeDesc.fixedValue)
        case .ratio:
            return Swift.max(0, contentResidual)
        case .wrap:
            assert(wrappedContent != nil)
            return Swift.min(sizeDesc.getWrapSize(by: wrappedContent!), contentResidual)
        case .aspectRatio:
            return 0
        }
    }

    static func getIntrinsicSize(from size: Size, contentResidual: CGSize, wrappedContent: CGSize? = nil) -> CGSize {
        if size.maybeWrap {
            assert(wrappedContent != nil)
        }
        // 约束包裹内容
        let content = wrappedContent?.clip(by: contentResidual)

        let width = getIntrinsic(from: size.width, contentResidual: contentResidual.width, wrappedContent: content?.width)
        let height = getIntrinsic(from: size.height, contentResidual: contentResidual.height, wrappedContent: content?.height)

        let intrinsic = CGSize(width: width, height: height)
        return intrinsic.expand(to: size.aspectRatio)
    }

    enum CalculateStrategy {
        case estimate
        case calculate
    }

    /// Measure 节点计算的统一入口
    /// `strategy`
    /// - Parameters:
    ///   - measure: measure
    ///   - layoutResidual: layoutResidual description
    ///   - strategy: positive: 同时计算子节点; negative: 若节点非包裹，则使用预估尺寸，子节点不会参与计算
    ///   - diagnosisMsg: diagnosisMsg description
    /// - Returns: Content size
    static func calculateIntrinsicSize(for measure: Measure, layoutResidual: CGSize, strategy: CalculateStrategy, diagnosisMsg: String? = nil) -> CGSize {
        var size: CGSize
        if measure.size.maybeWrap || strategy == .calculate {
            size = measure.calculate(by: layoutResidual)
        } else {
            size = getEstimateIntrinsic(for: measure, layoutResidual: layoutResidual)
        }
        DiagnosisUitl.startDiagnosis(measure: measure, residual: layoutResidual, intrinsic: size, msg: diagnosisMsg)
        return size
    }

    /// 不通过计算子节点获取估算尺寸，当size maybeWrap时不可用
    /// - Parameters:
    ///   - measure: measure description
    ///   - layoutResidual: layoutResidual description
    /// - Returns: description
    static func getEstimateIntrinsic(for measure: Measure, layoutResidual: CGSize) -> CGSize {
        assert(measure.size.bothNotWrap)
        let contentResidual = ResidualHelper.getContentResidual(layoutResidual: layoutResidual, margin: measure.margin, size: measure.size)
        return IntrinsicSizeHelper.getIntrinsicSize(from: measure.size, contentResidual: contentResidual)
    }

    static func sizeThatFit(size: CGSize, to measure: Measure) -> CGSize {
        var layoutResidual = size
        if layoutResidual.width == 0 { layoutResidual.width = .greatestFiniteMagnitude }
        if layoutResidual.height == 0 { layoutResidual.height = .greatestFiniteMagnitude }
        return calculateIntrinsicSize(for: measure, layoutResidual: layoutResidual, strategy: .estimate)
    }
}
