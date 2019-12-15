//
//  ScrollRegulator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/15.
//

import UIKit

public class ScrollRegulator: FlatRegulator {
    public override func caculate(byParent parent: Measure, remain size: CGSize) -> Size {
        return ScrollCaculator(self, parent: parent, remain: size).caculate()
    }
}

class ScrollCaculator {
    init(_ regulator: ScrollRegulator, parent: Measure, remain: CGSize) {
        self.regulator = regulator
        self.parent = parent
        self.remain = remain
    }

    let regulator: ScrollRegulator
    let parent: Measure
    let remain: CGSize
    
    func caculate() -> Size {
        return Size()
    }
}
