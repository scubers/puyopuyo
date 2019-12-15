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
    /// - Parameter direction: direction description
    /// - Returns: return value 返回的Size的main和cross都不可能是wrap，一定是固定值或者比重
//    func caculate(byParent parent: Measure) -> Size
    func caculate(byParent parent: Measure, remain size: CGSize) -> Size
}

public protocol MeasureTargetable: class {
    var py_size: CGSize { get set }
    
    var py_center: CGPoint { get set }

    func py_enumerateChild(_ block: (Int, Measure) -> Void)

    func py_sizeThatFits(_ size: CGSize) -> CGSize
    
}
