//
//  Size.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import UIKit

public protocol MeasureMetricChangedDelegate: AnyObject {
    func metricDidChanged(for mesure: Measure)
}

public protocol MeasureChildrenDelegate: AnyObject {
    func children(for measure: Measure) -> [Measure]
    func measureIsLayoutEntry(_ measure: Measure) -> Bool
}

public protocol MeasureSizeFittingDelegate: AnyObject {
    func measure(_ measure: Measure, sizeThatFits size: CGSize) -> CGSize
}

public class Measure {
    public weak var changeDelegate: MeasureMetricChangedDelegate?
    public weak var sizeDelegate: MeasureSizeFittingDelegate?
    public weak var childrenDelegate: MeasureChildrenDelegate?

    public init(delegate: MeasureMetricChangedDelegate?, sizeDelegate: MeasureSizeFittingDelegate?, childrenDelegate: MeasureChildrenDelegate?) {
        self.changeDelegate = delegate
        self.sizeDelegate = sizeDelegate
        self.childrenDelegate = childrenDelegate
    }

    private var notifier = SimpleIO<Void>()

    public var margin = UIEdgeInsets.zero {
        didSet {
            if oldValue != margin {
                notifyDidChange()
            }
        }
    }

    public var alignment: Alignment = .none {
        didSet {
            if oldValue != alignment {
                notifyDidChange()
            }
        }
    }

    public var size: Size = .init(width: .wrap, height: .wrap) {
        didSet {
            if oldValue != size {
                notifyDidChange()
            }
        }
    }

    ///
    /// Only works in `FlowRegulator`
    public var flowEnding: Bool = false {
        didSet {
            if oldValue != flowEnding {
                notifyDidChange()
            }
        }
    }

    ///
    /// Join the layout's calculation
    public var activated: Bool = true {
        didSet {
            if oldValue != activated {
                notifyDidChange()
            }
        }
    }

    public var isLayoutEntryPoint: Bool {
        childrenDelegate?.measureIsLayoutEntry(self) ?? false
    }

    public var diagnosisId: String?

    public var extraDiagnosisMessage: String?

    public var diagnosisMessage: String {
        """
        [\(type(of: self)), delegate: \(String(describing: changeDelegate))]
        - id: [\(diagnosisId ?? "")]
        - extra: [\(extraDiagnosisMessage ?? "")]
        - isLayoutEntryPoint: [\(isLayoutEntryPoint)]
        - size: [width: \(size.width), height: \(size.height)]
        - alignment: [\(alignment)]
        - margin: [top: \(margin.top), left: \(margin.left), bottom: \(margin.bottom), right: \(margin.right)]
        - flowEnding: [\(flowEnding)]
        """
    }

    public var calculatedSize: CGSize = .zero

    public var calculatedOrigin: CGPoint {
        CGPoint.getOrigin(center: calculatedCenter, size: calculatedSize)
    }

    public var calculatedFrame: CGRect {
        CGRect(origin: calculatedOrigin, size: calculatedSize)
    }

    public var calculatedCenter: CGPoint = .zero

    public var calculatedSizeWithMargin: CGSize {
        calculatedSize.expand(edge: margin).ensureNotNegative()
    }

    public func enumerateChildren(_ block: (Measure) -> Void) {
        children.forEach(block)
    }

    public func sizeThatFits(_ size: CGSize) -> CGSize {
        sizeDelegate?.measure(self, sizeThatFits: size) ?? .zero
    }

    public func notifyDidChange() {
        changeDelegate?.metricDidChanged(for: self)
        notifier.input(value: ())
    }

    public func calculate(by layoutResidual: CGSize) -> CGSize {
        if calculator == nil {
            calculator = createCalculator()
        }
        return doRunLoopCostMonitor {
            calculator!.calculate(self, layoutResidual: layoutResidual)
        }
    }

    public private(set) var calculator: Calculator?

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

extension Measure: ChangeNotifier {
    public var changeNotifier: Outputs<Void> {
        notifier.asOutput()
    }
}
