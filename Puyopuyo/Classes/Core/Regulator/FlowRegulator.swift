//
//  FlowLayout.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/8/20.
//

import Foundation

/// 流式布局
public class FlowRegulator: FlatRegulator {
    /// 每排的数量，若设置为0，则根据内容排列，性能较指定数量低，若非必要，可以指定数量
    public var arrange: Int = 1 {
        didSet {
            if oldValue != arrange {
                py_setNeedsRelayout()
            }
        }
    }

    /// 竖直方向上的间距
    public var vSpace: CGFloat = 0 {
        didSet {
            if oldValue != vSpace {
                py_setNeedsRelayout()
            }
        }
    }

    /// 水平方向上的间距
    public var hSpace: CGFloat = 0 {
        didSet {
            if oldValue != hSpace {
                py_setNeedsRelayout()
            }
        }
    }

    /// 同时设置xy方向上的间距
    override public var space: CGFloat {
        didSet {
            vSpace = space
            hSpace = space
        }
    }

    public var vFormat: Format = .leading {
        didSet {
            if oldValue != vFormat {
                py_setNeedsRelayout()
            }
        }
    }

    public var hFormat: Format = .leading {
        didSet {
            if oldValue != hFormat {
                py_setNeedsRelayout()
            }
        }
    }

    override public var format: Format {
        didSet {
            vFormat = format
            hFormat = format
        }
    }

    /// 平分flow的每一行
    public var stretchRows = false {
        didSet {
            if oldValue != stretchRows {
                py_setNeedsRelayout()
            }
        }
    }

    override public func calculate(byParent parent: Measure, remain size: CGSize) -> Size {
        return FlowCalculator(self, parent: parent, remain: size).calculate()
    }
}
