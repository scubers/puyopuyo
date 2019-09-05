//
//  FlowLayout.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/8/20.
//

import Foundation

public class FlowRegulator: FlatRegulator {
    
    public var arrange: Int = 0
    
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
