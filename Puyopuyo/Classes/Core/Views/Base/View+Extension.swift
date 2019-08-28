//
//  View+Extension.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/23.
//

import Foundation

public protocol MeasureHolder {
//    func py_getMeasure() -> Measure
    var py_measure: Measure { get }
}

extension UIView: MeasureHolder {

    public var py_measure: Measure {
        return MeasureFactory.getMeasure(from: self)
    }
}

private var py_measureChangedKey = "py_measureChangedKey"

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
    
    public func py_measureChanged<V: ValueOutputing & ValueInputing>() -> V where V.OutputType == CGRect, V.InputType == CGRect {
        if let s = objc_getAssociatedObject(self, &py_measureChangedKey) as? State<CGRect> {
            return s as! V
        }
        let s = State<CGRect>(frame)
        objc_setAssociatedObject(self, &py_measureChangedKey, s, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return s as! V
    }
    
}
