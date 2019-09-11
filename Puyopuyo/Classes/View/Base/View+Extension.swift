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
            case .visible: fallthrough
            case .free: isHidden = false
            default: isHidden = true
            }
            // activated
            switch newValue {
            case .visible: fallthrough
            case .invisible: py_measure.activated = true
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
                .yo.map({ (rect: CGRect?) in rect ?? .zero})
                .yo.distinct()
    }
    
    public func py_centerState() -> SimpleOutput<CGPoint> {
        return
            py_observing(for: #keyPath(UIView.center))
                .yo.map({ (x: CGPoint?) in x ?? .zero})
                .yo.distinct()
    }
    
    public func py_frameStateByBoundsCenter() -> SimpleOutput<CGRect> {
        
        let bounds = py_boundsState().yo.map({_ in CGRect.zero})
        let center = py_centerState().yo.map({_ in CGRect.zero})
        return
            SimpleOutput.merge([bounds, center])
                .yo.map({ [weak self] (_) -> CGRect in
                    guard let self = self else { return .zero }
                    return self.frame
                })
        // 因为这里是合并，不知道为何不能去重
    }
    
    public func py_frameStateByKVO() -> SimpleOutput<CGRect> {
        return
            py_observing(for: #keyPath(UIView.frame))
                .yo.map({ (x: CGRect?) in x ?? .zero})
                .yo.distinct()
    }

}
