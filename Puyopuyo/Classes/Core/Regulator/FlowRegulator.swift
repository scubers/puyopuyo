//
//  FlowLayout.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/8/20.
//

import Foundation

/// 流式布局
public class FlowRegulator: FlatRegulator {
    /// 每排的数量，若设置为0，则根据内容排列，性能较指定数量低，若非必要，可以指定数量
    public var arrange: Int = 1
    
    /// 竖直方向上的间距
    public var vSpace: CGFloat = 0
    
    /// 水平方向上的间距
    public var hSpace: CGFloat = 0
    
    /// 同时设置xy方向上的间距
    public override var space: CGFloat {
        didSet {
            vSpace = space
            hSpace = space
        }
    }

    public var vFormat: Format = .leading
    public var hFormat: Format = .leading

    public override var format: Format {
        didSet {
            vFormat = format
            hFormat = format
        }
    }
    
    /// 平分flow的每一行
    public var stretchRows = false

    public override func caculate(byParent parent: Measure, remain size: CGSize) -> Size {
        return FlowCaculator(self, parent: parent, remain: size).caculate()
    }
}
