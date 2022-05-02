//
//  View+Extension.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/23.
//

import Foundation

@available(*, deprecated)
public extension UIView {
    @available(*, deprecated, message: "Use [UIView.layoutMeasure]")
    var py_measure: Measure {
        layoutMeasure
    }

    @available(*, deprecated, message: "Use [BoxLayoutNode.layoutVisibility]")
    var py_visibility: Visibility {
        get { layoutVisibility }
        set { layoutVisibility = newValue }
    }
}

// MARK: - MeasureTargetable impl

extension UIView: MeasureMetricChangedDelegate, MeasureSizeFittingDelegate {
    public func measure(_ measure: Measure, sizeThatFits size: CGSize) -> CGSize {
        sizeThatFits(size)
    }

    public func metricDidChanged(for mesure: Measure) {
        if let superview = superview, superview.isBoxView {
            superview.setNeedsLayout()
        }
        setNeedsLayout()
    }

    func py_setNeedsRelayout() {
        metricDidChanged(for: layoutMeasure)
    }

    func py_setNeedsLayoutIfMayBeWrap() {
        if layoutMeasure.size.maybeWrap {
            py_setNeedsRelayout()
        }
    }
}

// MARK: - UIView animator

public extension UIView {
    private static var py_animatorKey = "py_animatorKey"
    var py_animator: Animator? {
        set {
            objc_setAssociatedObject(self, &UIView.py_animatorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            objc_getAssociatedObject(self, &UIView.py_animatorKey) as? Animator
        }
    }
}

// MARK: - UIView ext methods

public extension UIView {
    func py_originState() -> Outputs<CGPoint> {
        py_frameState().map(\.origin).distinct()
    }

    func py_sizeState() -> Outputs<CGSize> {
        Outputs.merge([py_boundsState(), py_frameState()]).map(\.size).distinct()
    }

    func py_boundsState() -> Outputs<CGRect> {
        py_observing(\.bounds).unwrap(or: .zero).distinct()
    }

    func py_frameState() -> Outputs<CGRect> {
        py_observing(\.frame).unwrap(or: .zero).distinct()
    }

    func py_centerState() -> Outputs<CGPoint> {
        py_observing(\.center).unwrap(or: .zero).distinct()
    }

    /// ios11监听safeAreaInsets, ios10及以下，则监听frame变化并且通过转换坐标后得到与statusbar的差距
    func py_safeArea() -> Outputs<UIEdgeInsets> {
        if #available(iOS 11, *) {
            return py_observing(\.safeAreaInsets).unwrap(or: .zero).distinct()
        } else {
            // ios 11 以下只可能存在statusbar影响的safeArea
            let this = WeakableObject(value: self)
            return
                Outputs.merge([
                    py_frameState().distinct().map { _ in 1 },
                    py_centerState().distinct().map { _ in 1 },
                    py_boundsState().distinct().map { _ in 1 },
                ])
                .map { _ -> UIEdgeInsets in
                    guard let this = this.value else { return .zero }
                    let newRect = this.convert(this.bounds, to: UIApplication.shared.keyWindow)
                    var insets = UIEdgeInsets.zero
                    let statusBarFrame = UIApplication.shared.statusBarFrame
                    insets.top = Swift.min(statusBarFrame.height, Swift.max(0, statusBarFrame.height - newRect.origin.y))
                    return insets
                }
                .distinct()
        }
    }
}

public extension Bool {
    /// return if visible or gone
    func py_visibleOrGone() -> Visibility {
        return self ? .visible : .gone
    }

    /// return if visible or invisible
    func py_visibleOrNot() -> Visibility {
        return self ? .visible : .invisible
    }

    func py_toggled() -> Bool { !self }

    mutating func py_toggle() { self = !self }
}

public extension UIView {
    var isPositionZero: Bool {
        bounds.size == .zero && center == .zero
    }
}
