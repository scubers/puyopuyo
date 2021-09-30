//
//  BaseLayout.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

public class Regulator: Measure {
    ///
    /// Justify children's alignment.
    /// Will be override by child's `alignment`
    public var justifyContent: Alignment = .center {
        didSet {
            if oldValue != justifyContent {
                py_setNeedsRelayout()
            }
        }
    }

    public var padding = UIEdgeInsets.zero {
        didSet {
            if oldValue != padding {
                py_setNeedsRelayout()
            }
        }
    }

    public var calculateChildrenImmediately = false {
        didSet {
            if oldValue != calculateChildrenImmediately {
                py_setNeedsRelayout()
            }
        }
    }

    override public var diagnosisMessage: String {
        """
        \(super.diagnosisMessage)
        - padding: [top: \(padding.top), left: \(padding.left), bottom: \(padding.bottom), right: \(padding.right)]
        - justifyContent: [\(justifyContent)]
        - calculateChildrenImmediately: [\(calculateChildrenImmediately)]
        """
    }
}
