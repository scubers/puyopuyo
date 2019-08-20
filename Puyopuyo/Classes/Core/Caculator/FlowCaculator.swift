//
//  FlowCaculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/8/20.
//

import Foundation

class FlowCaculator {
    let layout: FlowLayout
    let parent: Measure
    init(_ layout: FlowLayout, parent: Measure) {
        self.layout = layout
        self.parent = parent
    }
    
    func caculate() -> Size {
        return Size()
    }
}
