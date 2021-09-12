//
//  Caculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import UIKit

public protocol Measurable {
    /// 计算尺寸
    ///
    func calculate(remain size: CGSize) -> Size
}

public protocol MeasureTargetable: AnyObject {
    var py_size: CGSize { get set }

    var py_center: CGPoint { get set }

    func py_enumerateChild(_ block: (Measure) -> Void)

    func py_sizeThatFits(_ size: CGSize) -> CGSize

    func py_setNeedsRelayout()
}
