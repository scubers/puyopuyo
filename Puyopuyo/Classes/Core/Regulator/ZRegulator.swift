//
//  ZLayout.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

public class ZRegulator: Regulator {
    override public func caculate(byParent parent: Measure, remain size: CGSize) -> Size {
        return ZCaculator(self, parent: parent, remain: size).caculate()
    }
}

public protocol Resizable {
    func resizing() -> Outputs<CGRect>
}

extension UIView: Resizable {
    public func resizing() -> Outputs<CGRect> {
        return py_frameStateByKVO()
    }
}

extension Simulate {
    func adapt() -> Outputs<CGFloat> {
        let transform = self.transform
        let actions = self.actions
        return
            Outputs
                .merge([view.py_frameStateByKVO(), view.py_frameStateByBoundsCenter()])
                .distinct()
                .map { actions.reduce(transform($0)) { $1($0) } }
                .distinct()
    }
}
