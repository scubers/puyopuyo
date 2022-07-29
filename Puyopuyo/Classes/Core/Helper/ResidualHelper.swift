//
//  ResidualHelper.swift
//  Puyopuyo
//
//  Created by J on 2022/5/15.
//

import Foundation

///
/// 相关概念：
/// layoutResidual: 提供给 布局 参与布局的空间（包含margin）
/// contentResidual: View 实际可用的最大空间（不包含margin），且必须满足 size.aspectRatio 的宽高比
enum ResidualHelper {
    /// 获取布局时候的初始化LayoutResidual
    /// - Parameter measure: measure description
    /// - Parameter constraint: constraint description
    /// - Returns: layoutResidual
    static func getInitialLayoutResidual(for measure: Measure, contentConstraint: CGSize = .init(width: -1, height: -1)) -> CGSize {
        func getInitialContentResidual(for sizeDesc: SizeDescription, constraint: CGFloat) -> CGFloat {
            switch sizeDesc.sizeType {
            case .fixed:
                return sizeDesc.fixedValue
            case .ratio:
                return constraint < 0 ? 0 : constraint
            case .wrap:
                return constraint < 0 ? sizeDesc.max : constraint
            case .aspectRatio:
                return constraint < 0 ? .greatestFiniteMagnitude : constraint
            }
        }

        let contentResidual = CGSize(
            width: getInitialContentResidual(for: measure.size.width, constraint: contentConstraint.width),
            height: getInitialContentResidual(for: measure.size.height, constraint: contentConstraint.height)
        )
        .ensureNotNegative()

        return getSelfLayoutResidual(for: measure, fromContentResidual: contentResidual)
    }

    /// 已知当前节点的内容尺寸，获取其布局时的最小剩余布局
    /// - Parameters:
    ///   - measure: measure
    ///   - contentResidual: contentResidual description
    /// - Returns: layoutResidual
    static func getSelfLayoutResidual(for measure: Measure, fromContentResidual contentResidual: CGSize) -> CGSize {
        return contentResidual
            .expand(edge: measure.margin.getFixedSize())
            .ensureNotNegative()
    }

    /// 根据layoutResidual和相关约束，获取当前节点的contentResidual
    /// - Parameters:
    ///   - layoutResidual: layoutResidual description
    ///   - margin: margin description
    ///   - size: size description
    /// - Returns: contentResidual
    static func getContentResidual(layoutResidual: CGSize, margin: BorderInsets, size: Size) -> CGSize {
        var residual = layoutResidual
            .collapse(edge: margin.getFixedSize())
            .ensureNotNegative()

        if size.width.isFixed { residual.width = size.width.fixedValue }
        if size.height.isFixed { residual.height = size.height.fixedValue }

        // 可能被最大值约束
        residual = residual.clip(by: CGSize(width: size.width.max, height: size.height.max))

        return residual.collapse(to: size.aspectRatio)
    }

    /// 布局节点吱声layoutResidual 获取子节点总共可用 layoutResidual
    /// - Parameters:
    ///   - regulator: regulator description
    ///   - regulatorLayoutResidual: regulatorLayoutResidual description
    /// - Returns: description
    static func getChildrenLayoutResidual(for regulator: Regulator, regulatorLayoutResidual: CGSize) -> CGSize {
        let regulatorContentResidual = getContentResidual(layoutResidual: regulatorLayoutResidual, margin: regulator.margin, size: regulator.size)
        return regulatorContentResidual
            .collapse(edge: regulator.padding.getFixedSize())
            .ensureNotNegative()
    }
}
