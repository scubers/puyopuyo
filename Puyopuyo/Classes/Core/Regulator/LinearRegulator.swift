//
//  LineLayout.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

public class LinearRegulator: Regulator {
    override public init(delegate: MeasureDelegate?) {
        super.init(delegate: delegate)
        justifyContent = [.left, .top]
    }

    ///
    /// Layout direction
    public var direction: Direction = .x {
        didSet {
            if oldValue != direction {
                py_setNeedsRelayout()
            }
        }
    }

    ///
    /// Space between items
    public var space: CGFloat = 0 {
        didSet {
            if oldValue != space {
                py_setNeedsRelayout()
            }
        }
    }

    ///
    /// Tell layout how to place the subview in main direction
    public var format: Format = .leading {
        didSet {
            if oldValue != format {
                py_setNeedsRelayout()
            }
        }
    }

    ///
    /// Reverse the chilren
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

    override public func createCalculator() -> Calculator {
        LinearCalculator(estimateChildren: true)
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
