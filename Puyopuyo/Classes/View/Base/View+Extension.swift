//
//  View+Extension.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/23.
//

import Foundation

public protocol MeasureHolder {
    var py_measure: Measure { get }
}

// MARK: - MeasureHolder impl

extension UIView: MeasureHolder {
    public var py_measure: Measure {
        return MeasureFactory.getMeasure(from: self)
    }
}

// MARK: - MeasureTargetable impl

extension UIView: MeasureTargetable {
    public var py_size: CGSize {
        get {
            return bounds.size
        }
        set {
            bounds.size = CGSize(width: max(newValue.width, 0), height: max(newValue.height, 0))
        }
    }

    public var py_center: CGPoint {
        get {
            return center
        }
        set {
            center = newValue
            didChangeValue(forKey: #keyPath(UIView.center))
        }
    }

    public func py_enumerateChild(_ block: (Int, Measure) -> Void) {
        subviews.enumerated().forEach {
            block($0, $1.py_measure)
        }
    }

    public func py_sizeThatFits(_ size: CGSize) -> CGSize {
        return sizeThatFits(size)
    }
}

// MARK: - UIView ext methods

extension UIView {
    public var py_visibility: Visibility {
        set {
            // hidden
            switch newValue {
            case .visible, .free: isHidden = false
            default: isHidden = true
            }
            // activated
            switch newValue {
            case .visible, .invisible: py_measure.activated = true
            default: py_measure.activated = false
            }
        }
        get {
            switch (py_measure.activated, isHidden) {
            case (true, false): return .visible
            case (true, true): return .invisible
            case (false, true): return .gone
            case (false, false): return .free
            }
        }
    }

    public func py_mayBeWrap() -> Bool {
        return py_measure.size.maybeWrap()
    }

    public func py_boundsState() -> SimpleOutput<CGRect> {
        return
            py_observing(for: #keyPath(UIView.bounds))
                .map { (rect: CGRect?) in rect ?? .zero }
                .distinct()
    }

    public func py_centerState() -> SimpleOutput<CGPoint> {
        return
            py_observing(for: #keyPath(UIView.center))
                .map { (x: CGPoint?) in x ?? .zero }
                .distinct()
    }

    public func py_frameStateByBoundsCenter() -> SimpleOutput<CGRect> {
        let bounds = py_boundsState().map { _ in CGRect.zero }
        let center = py_centerState().map { _ in CGRect.zero }
        return
            SimpleOutput.merge([bounds, center])
                .map { [weak self] (_) -> CGRect in
                    guard let self = self else { return .zero }
                    return self.frame
                }
        // 因为这里是合并，不知道为何不能去重
    }

    public func py_frameStateByKVO() -> SimpleOutput<CGRect> {
        return
            py_observing(for: #keyPath(UIView.frame))
                .map { (x: CGRect?) in x ?? .zero }
                .distinct()
    }

    /// ios11监听safeAreaInsets, ios10及以下，则监听frame变化并且通过转换坐标后得到与statusbar的差距
    public func py_safeArea() -> SimpleOutput<UIEdgeInsets> {
        if #available(iOS 11, *) {
            return py_observing(for: #keyPath(UIView.safeAreaInsets)).map { (insets: UIEdgeInsets?) in insets ?? .zero }.distinct()
        } else {
            // ios 11 以下只可能存在statusbar影响的safeArea
            return
                SimpleOutput.merge([py_frameStateByBoundsCenter(), py_frameStateByKVO()])
                    .map { [weak self] _ -> UIEdgeInsets in
                        guard let self = self else { return .zero }
                        let newRect = self.convert(self.bounds, to: UIApplication.shared.keyWindow)
                        var inset = UIEdgeInsets.zero
                        let statusFrame = UIApplication.shared.statusBarFrame
                        inset.top = min(statusFrame.height, max(0, statusFrame.height - newRect.origin.y))
                        return inset
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

    func py_toggled() -> Bool {
        return !self
    }
}
