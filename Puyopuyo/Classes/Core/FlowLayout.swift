//
//  FlowLayout.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

public class FlowLayout: FlatLayout {
    
    public var arrangeCount: Int = 1
    
    public var xSpace: CGFloat = 0
    public var ySpace: CGFloat = 0
    
    public var subFormation: Formation = .leading
    
    public override var space: CGFloat {
        didSet {
            xSpace = space
            ySpace = space
        }
    }
    
    public override func caculate(byParent parent: Measure) -> Size {
        return FlowCaculator(self, parent: parent).caculate()
    }
}
