//
//  LineLayout.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

public class FlatLayout: BaseLayout {
    
    public override init(target: MeasureTargetable? = nil) {
        super.init(target: target)
        justifyContent = [.left, .top]
    }
    
    public var space: CGFloat = 0
    
    public var formation: Formation = .leading
    
    public var reverse = false
    
    public var autoJudgeScroll = true
    
    public override func caculate(byParent parent: Measure) -> Size {
        return FlatCaculator(self, parent: parent).caculate()
    }
}
