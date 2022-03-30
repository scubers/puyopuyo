//
//  Size.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import UIKit

public protocol MeasureDelegate: AnyObject {
    func children(for measure: Measure) -> [Measure]

    func measure(_ measure: Measure, sizeThatFits size: CGSize) -> CGSize

    func needsRelayout(for measure: Measure)
}

public class Measure {
    public weak var delegate: MeasureDelegate?

    public init(delegate: MeasureDelegate?) {
        self.delegate = delegate
    }

    public var margin = UIEdgeInsets.zero {
        didSet {
            if oldValue != margin {
                py_setNeedsRelayout()
            }
        }
    }

    public var alignment: Alignment = .none {
        didSet {
            if oldValue != alignment {
                py_setNeedsRelayout()
            }
        }
    }

    public var size = Size(width: .wrap, height: .wrap) {
        didSet {
            if oldValue != size {
                py_setNeedsRelayout()
            }
        }
    }

    ///
    /// Only works in `FlowRegulator`
    public var flowEnding = false {
        didSet {
            if oldValue != flowEnding {
                py_setNeedsRelayout()
            }
        }
    }

    ///
    /// Join the layout's calculation
    public var activated = true {
        didSet {
            if oldValue != activated {
                py_setNeedsRelayout()
            }
        }
    }

    public var diagnosisId: String?

    public var extraDiagnosisMessage: String?

    public var diagnosisMessage: String {
        """
        [\(type(of: self)), delegate: \(String(describing: delegate))]
        - id: [\(diagnosisId ?? "")]
        - extra: [\(extraDiagnosisMessage ?? "")]
        - size: [width: \(size.width), height: \(size.height)]
        - alignment: [\(alignment)]
        - margin: [top: \(margin.top), left: \(margin.left), bottom: \(margin.bottom), right: \(margin.right)]
        - flowEnding: [\(flowEnding)]
        """
    }

    public var calculatedSize: CGSize = .zero

    public var calculatedCenter: CGPoint = .zero

    public var calculatedSizeWithMargin: CGSize {
        CGSize.ensureNotNegative(width: calculatedSize.width + margin.getHorzTotal(), height: calculatedSize.height + margin.getVertTotal())
    }

    public func enumerateChildren(_ block: (Measure) -> Void) {
        delegate?.children(for: self).forEach(block)
    }

    public func sizeThatFits(_ size: CGSize) -> CGSize {
        delegate?.measure(self, sizeThatFits: size) ?? .zero
    }

    public func py_setNeedsRelayout() {
        delegate?.needsRelayout(for: self)
    }

    public func calculate(by residual: CGSize) -> CGSize {
        return MeasureCalculator().calculate(self, layoutResidual: residual)
    }
}
