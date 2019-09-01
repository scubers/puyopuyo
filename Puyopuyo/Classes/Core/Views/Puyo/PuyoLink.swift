//
//  Puyo.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/23.
//

import Foundation

//public class Puyo<T: UIView> {
public class Puyo<T: UIView> {

    public private(set) var view: T
    
    public init(_ view: T) {
        self.view = view
    }
    
    func setNeedsLayout() {
        view.py_setNeedsLayout()
    }
    
    @discardableResult
    public func attach(_ parent: UIView? = nil, _ block: ((T) -> Void)? = nil) -> Puyo<T> {
        block?(view)
        parent?.addSubview(view)
        return self
    }
    
    static func ensureInactivate(_ view: UIView, _ msg: String = "") {
        assert(!view.py_measure.activated, msg)
    }
    
    @discardableResult
    public func receive<O: Outputing, R>(_ state: O, _ block: @escaping (T, R) -> Void) -> Self where O.OutputType == R {
        view.py_setUnbinder(state.safeBind(view, { (v, r) in
            block(v, r)
        }), for: "\(#function)_\(Date().timeIntervalSince1970)")
        return self
    }
}

public typealias PuyoBlock = (UIView) -> Void

public protocol PuyoAttacher {
    associatedtype Holder: UIView
    func attach(_ parent: UIView?, _ block: PuyoBlock?) -> Puyo<Holder>
}

extension PuyoAttacher where Self: UIView {
    
    @discardableResult
    public func attach(_ parent: UIView? = nil, _ block: PuyoBlock? = nil) -> Puyo<Self> {
        let link = Puyo(self)
        block?(self)
        parent?.addSubview(self)
        return link
    }
    
}

extension UIView: PuyoAttacher {
    func py_setNeedsLayout() {
        setNeedsLayout()
        if let superview = superview as? BoxView {
            superview.setNeedsLayout()
        }
    }
}
