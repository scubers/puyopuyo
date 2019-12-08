//
//  LineLayout.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

public class FlatRegulator: Regulator {
    public override init(target: MeasureTargetable? = nil, children: [Measure] = []) {
        super.init(target: target, children: children)
        justifyContent = [.left, .top]
    }

    public var space: CGFloat = 0

    public var format: Format = .leading

    public var reverse = false

    public override func caculate(byParent parent: Measure, remain size: CGSize) -> Size {
        return FlatCaculator(self, parent: parent, remain: size).caculate()
    }
}
