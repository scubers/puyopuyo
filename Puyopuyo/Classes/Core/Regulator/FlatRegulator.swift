//
//  LineLayout.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

/// 平面布局
public class FlatRegulator: Regulator {
    public override init(target: MeasureTargetable? = nil, children: [Measure] = []) {
        super.init(target: target, children: children)
        justifyContent = [.left, .top]
    }
    
    /// 间隔
    public var space: CGFloat = 0
    
    /// 主轴格式
    public var format: Format = .leading
    
    /// 是否根据子节点进行反向遍历布局
    public var reverse = false

    public override func caculate(byParent parent: Measure, remain size: CGSize) -> Size {
        return FlatCaculator(self, parent: parent, remain: size).caculate()
    }
}
