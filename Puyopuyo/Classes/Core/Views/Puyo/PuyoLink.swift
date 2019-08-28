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
