//
//  LineLayout.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

/// 平面布局
public class FlatRegulator: Regulator {
    override public init(target: MeasureTargetable? = nil, children: [Measure] = []) {
        super.init(target: target, children: children)
        justifyContent = [.left, .top]
    }

    /// 间隔
    public var space: CGFloat = 0 {
        didSet {
            if oldValue != space {
                py_setNeedsRelayout()
            }
        }
    }

    /// 主轴格式
    public var format: Format = .leading {
        didSet {
            if oldValue != format {
                py_setNeedsRelayout()
            }
        }
    }

    /// 是否根据子节点进行反向遍历布局
    public var reverse = false {
        didSet {
            if oldValue != reverse {
                py_setNeedsRelayout()
            }
        }
    }

    override public func calculate(byParent parent: Measure, remain size: CGSize) -> Size {
//        return FlatCalculator(self, parent: parent, remain: size).calculate()
        return FlatCalculator2(self, parent: parent, remain: size).calculate()
    }
}
