//
//  BaseLayout.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

public class Regulator: Measure {
    public var semanticDirection: SemanticDirection? {
        didSet {
            if oldValue != semanticDirection {
                notifyDidChange()
            }
        }
    }

    ///
    /// Justify children's alignment.
    /// Will be override by child's `alignment`
    public var justifyContent: Alignment = .center {
        didSet {
            if oldValue != justifyContent {
                notifyDidChange()
            }
        }
    }

    public var padding = BorderInsets.zero {
        didSet {
            if oldValue != padding {
                notifyDidChange()
            }
        }
    }

    override public var diagnosisMessage: String {
        """
        \(super.diagnosisMessage)
        - semanticDirection: [\(semanticDirection.debugDescription)]
        - padding: [top: \(padding.top), left: \(padding.left), bottom: \(padding.bottom), right: \(padding.right)]
        - justifyContent: [\(justifyContent)]
        """
    }

    override public func createCalculator() -> Calculator {
        fatalError("subclass impl")
    }
}
