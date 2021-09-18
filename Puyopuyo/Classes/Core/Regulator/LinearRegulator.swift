//
//  LineLayout.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

public class LinearRegulator: Regulator {
    override public init(delegate: MeasureDelegate? = nil, children: [Measure] = []) {
        super.init(delegate: delegate, children: children)
        justifyContent = [.left, .top]
    }

    public var direction: Direction = .x {
        didSet {
            if oldValue != direction {
                py_setNeedsRelayout()
            }
        }
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

    public func getCalPadding() -> CalEdges {
        return CalEdges(insets: padding, direction: direction)
    }

    override public func calculate(by size: CGSize) -> CGSize {
        return LinearCalculator(self, residual: size, isIntrinsic: false).calculate()
    }

    override public var diagnosisMessage: String {
        """
        \(super.diagnosisMessage)
        - direction: [\(direction)]
        - space: [\(space)]
        - format: [\(format)]
        - reverse: [\(reverse)]
        """
    }
}
