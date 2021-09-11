//
//  FlowLayout.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/8/20.
//

import Foundation

/// 流式布局
public class FlowRegulator: FlatRegulator {
    /// 每排的数量，若设置为0，则根据内容排列
    public var arrange: Int = 0 {
        didSet {
            if oldValue != arrange {
                py_setNeedsRelayout()
            }
        }
    }

    // 单排内item的检具
    public var itemSpace: CGFloat = 0 {
        didSet {
            if oldValue != itemSpace {
                py_setNeedsRelayout()
            }
        }
    }

    // 每排的间距
    public var runSpace: CGFloat = 0 {
        didSet {
            if oldValue != runSpace {
                py_setNeedsRelayout()
            }
        }
    }

    /// 同时设置item & run space
    override public var space: CGFloat {
        didSet {
            itemSpace = space
            runSpace = space
        }
    }

    public var runFormat: Format = .leading {
        didSet {
            if oldValue != runFormat {
                py_setNeedsRelayout()
            }
        }
    }

    public var runingRowSize: (Int) -> SizeDescription = { _ in SizeDescription.wrap(shrink: 1) } {
        didSet {
            py_setNeedsRelayout()
        }
    }

    override public func calculate(byParent parent: Measure, remain size: CGSize) -> Size {
        return FlowCalculator(self, parent: parent, remain: size).calculate()
    }
}
