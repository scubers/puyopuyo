//
//  FlowLayout.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/8/20.
//

import Foundation

/// Flow layout
/// Place subview in flow way,
/// HFlow         VFlow
///   | Run         -> Run
///   V
/// |----------|  |----------|
/// |0  1  2  3|  |0  3  6  9|
/// |4  5  6  7|  |1  4  7   |
/// |8  9      |  |2  5  8   |
/// |----------|  |----------|
///
public class FlowRegulator: LinearRegulator {
    /// The view count in every row.
    /// When set to `0`, it will auto calculate by content
    public var arrange: Int = 0 {
        didSet {
            if oldValue != arrange {
                py_setNeedsRelayout()
            }
        }
    }

    ///
    /// Subview's space in single row
    public var itemSpace: CGFloat = 0 {
        didSet {
            if oldValue != itemSpace {
                py_setNeedsRelayout()
            }
        }
    }

    ///
    /// Space between rows
    public var runSpace: CGFloat = 0 {
        didSet {
            if oldValue != runSpace {
                py_setNeedsRelayout()
            }
        }
    }

    ///
    /// Set item space and runSpace at the same time
    override public var space: CGFloat {
        didSet {
            itemSpace = space
            runSpace = space
        }
    }

    ///
    /// Row's format
    public var runFormat: Format = .leading {
        didSet {
            if oldValue != runFormat {
                py_setNeedsRelayout()
            }
        }
    }

    ///
    /// Every row's size in `run` direction
    public var runRowSize: (Int) -> SizeDescription = { _ in SizeDescription.wrap(shrink: 1) } {
        didSet {
            py_setNeedsRelayout()
        }
    }

    override public func createCalculator() -> Calculator {
        FlowCalculator(calculateChildrenImmediately: false)
    }

    override public var diagnosisMessage: String {
        """
        \(super.diagnosisMessage)
        - arrange: [\(arrange)]
        - runFormat: [\(runFormat)]
        - itemSpace: [\(itemSpace)]
        - runSpace: [\(runSpace)]
        """
    }
}
