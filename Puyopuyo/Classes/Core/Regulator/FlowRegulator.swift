//
//  FlowLayout.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/8/20.
//

import Foundation

public class FlowRegulator: FlatRegulator {
    
    /// 每排的数量，若设置为0，则根据内容排列，性能较指定数量低，若非必要，可以指定数量
    public var arrange: Int = 1
    
    public var vSpace: CGFloat = 0
    public var hSpace: CGFloat = 0
    
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
    
    public override func caculate(byParent parent: Measure) -> Size {
        return FlowCaculator(self, parent: parent).caculate()
    }
}
