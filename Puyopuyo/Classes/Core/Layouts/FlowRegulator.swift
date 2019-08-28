//
//  FlowLayout.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/8/20.
//

import Foundation

public class FlowRegulator: FlatRegulator {
    
    public var arrange: Int = 1 {
        willSet {
            assert(newValue > 0, "flow layout should not set count below 1!!")
        }
    }
    
    public var vSpace: CGFloat = 0
    public var hSpace: CGFloat = 0
    
    public override var space: CGFloat {
        didSet {
            vSpace = space
            hSpace = space
        }
    }
    
    public var subFormat: Format = .leading
    
    public override func caculate(byParent parent: Measure) -> Size {
        return FlowCaculator(self, parent: parent).caculate()
    }
}
