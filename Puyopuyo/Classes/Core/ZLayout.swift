//
//  ZLayout.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

public class ZLayout: BaseLayout {
    
    public override func caculate(byParent parent: Measure) -> Size {
        return ZCaculator(self, parent: parent).caculate()
    }
}
