//
//  Size.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import UIKit

public protocol MeasureDelegate: AnyObject {
    func needsRelayout(for measure: Measure)
}

public protocol MeasureChildrenDelegate: AnyObject {
    func children(for measure: Measure) -> [Measure]
}

public protocol MeasureSizeFittingDelegate: AnyObject {
    func measure(_ measure: Measure, sizeThatFits size: CGSize) -> CGSize
}

public class Measure {
    public weak var delegate: MeasureDelegate?
    public weak var sizeDelegate: MeasureSizeFittingDelegate?
    public weak var childrenDelegate: MeasureChildrenDelegate?

    public init(delegate: MeasureDelegate?, sizeDelegate: MeasureSizeFittingDelegate?, childrenDelegate: MeasureChildrenDelegate?) {
        self.delegate = delegate
        self.sizeDelegate = sizeDelegate
        self.childrenDelegate = childrenDelegate
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

    public var calculatedFrame: CGRect {
        CGRect(
            origin: CGPoint(
                x: calculatedCenter.x - calculatedSize.width / 2,
                y: calculatedCenter.y - calculatedSize.height / 2
            ),
            size: calculatedSize
        )
    }

    public var calculatedCenter: CGPoint = .zero

    public var calculatedSizeWithMargin: CGSize {
        CGSize.ensureNotNegative(width: calculatedSize.width + margin.getHorzTotal(), height: calculatedSize.height + margin.getVertTotal())
    }

    public func enumerateChildren(_ block: (Measure) -> Void) {
        children.forEach(block)
    }

    public func sizeThatFits(_ size: CGSize) -> CGSize {
        sizeDelegate?.measure(self, sizeThatFits: size) ?? .zero
    }

    public func py_setNeedsRelayout() {
        delegate?.needsRelayout(for: self)
    }

    public func calculate(by layoutResidual: CGSize) -> CGSize {
        calculator.calculate(self, layoutResidual: layoutResidual)
    }

    private lazy var calculator = createCalculator()

    /// subclass should override
    public func createCalculator() -> Calculator {
        if type(of: self) === Measure.self {
            return MeasureCalculator()
        }
        fatalError("subclass impl")
    }

    public var children: [Measure] {
        childrenDelegate?.children(for: self) ?? []
    }
}
