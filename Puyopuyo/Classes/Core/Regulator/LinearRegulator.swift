//
//  LineLayout.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

public class LinearRegulator: Regulator {
    override public init(delegate: MeasureMetricChangedDelegate?, sizeDelegate: MeasureSizeFittingDelegate?, childrenDelegate: MeasureChildrenDelegate?) {
        super.init(delegate: delegate, sizeDelegate: sizeDelegate, childrenDelegate: childrenDelegate)
        justifyContent = [.leading, .top]
    }

    ///
    /// Layout direction
    public var direction: Direction = .x {
        didSet {
            if oldValue != direction {
                notifyDidChange()
            }
        }
    }

    ///
    /// Space between items
    public var space: CGFloat = 0 {
        didSet {
            if oldValue != space {
                notifyDidChange()
            }
        }
    }

    ///
    /// Tell layout how to place the subview in main direction
    public var format: Format = .leading {
        didSet {
            if oldValue != format {
                notifyDidChange()
            }
        }
    }

    ///
    /// Reverse the chilren
    public var reverse = false {
        didSet {
            if oldValue != reverse {
                notifyDidChange()
            }
        }
    }

    public func getCalPadding() -> CalEdges {
        return CalEdges(insets: padding, direction: direction)
    }

    override public func createCalculator() -> Calculator {
        LinearCalculator()
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
