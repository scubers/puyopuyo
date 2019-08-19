//
//  PuyoLink.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/23.
//

import Foundation

public class PuyoLink<T: UIView> {
    
    public private(set) var view: T
    
    public init(_ view: T) {
        self.view = view
    }
    
    func setNeedsLayout() {
        view.py_setNeedsLayout()
    }
    
    @discardableResult
    public func attach(_ parent: UIView? = nil, _ block: ((T) -> Void)? = nil) -> PuyoLink<T> {
        block?(view)
        parent?.addSubview(view)
        return self
    }
}

public typealias PuyoLinkBlock = (UIView) -> Void

public protocol PuyoLinkAttacher {
    associatedtype Holder: UIView
    func attach(_ parent: UIView?, _ block: PuyoLinkBlock?) -> PuyoLink<Holder>
}

extension PuyoLinkAttacher where Self: UIView {
    
    @discardableResult
    public func attach(_ parent: UIView? = nil, _ block: PuyoLinkBlock? = nil) -> PuyoLink<Self> {
        let link = PuyoLink(self)
        block?(self)
        parent?.addSubview(self)
        return link
    }
    
}

extension UIView: PuyoLinkAttacher {
    func py_setNeedsLayout() {
        setNeedsLayout()
        if let superview = superview as? BoxView {
            superview.setNeedsLayout()
        }
    }
}
