//
//  PuyoLink.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/23.
//

import Foundation

public class PuyoLink<T: UIView> {
    
    public var view: T
    public init(_ view: T, wrap: Bool = true) {
        self.view = view
        if wrap {
            view.py_measure.size = Size(width: .wrap, height: .wrap)
        }
    }
}

public typealias PuyoLinkBlock = (UIView) -> Void

public protocol PuyoLinkAttacher {
    associatedtype Holder: UIView
    func attach(_ parent: UIView?, wrap: Bool, _ block: PuyoLinkBlock?) -> PuyoLink<Holder>
}

extension PuyoLinkAttacher where Self: UIView {
    
    @discardableResult
    public func attach(_ parent: UIView? = nil, wrap: Bool = true, _ block: PuyoLinkBlock? = nil) -> PuyoLink<Self> {
        let link = PuyoLink(self, wrap: wrap)
        block?(self)
        parent?.addSubview(self)
        return link
    }
    
}

extension UIView: PuyoLinkAttacher {
    
}

extension PuyoLink where T: UIView {
    
    @discardableResult
    public func visible(_ visibility: Visiblity) -> Self {
        PuyoLinkHelper.visibility(for: view, visibility: visibility)
        return self
    }
    @discardableResult
    public func size(width: SizeType? = nil, height: SizeType? = nil) -> Self {
        PuyoLinkHelper.size(for: view, width: width, height: height)
        return self
    }
    @discardableResult
    public func margin(all: CGFloat? = nil, top: CGFloat? = nil, left: CGFloat? = nil, bottom: CGFloat? = nil, right: CGFloat? = nil) -> Self {
        PuyoLinkHelper.margin(for: view, all: all, top: top, left: left, bottom: bottom, right: right)
        return self
    }

    @discardableResult
    public func aligment(_ aligment: Aligment) -> Self {
        PuyoLinkHelper.aligment(for: view, aligment: aligment)
        return self
    }    
}

extension PuyoLink where T: Line {
    @discardableResult
    public func crossAxis(_ aligment: Aligment) -> Self {
        view.layout.crossAxis = aligment
        view.setNeedsLayout()
        view.superview?.setNeedsLayout()
        return self
    }
    @discardableResult
    public func space(_ space: CGFloat) -> Self {
        view.layout.space = space
        view.setNeedsLayout()
        view.superview?.setNeedsLayout()
        return self
    }
    @discardableResult
    public func formation(_ formation: Formation) -> Self {
        view.layout.formation = formation
        view.setNeedsLayout()
        view.superview?.setNeedsLayout()
        return self
    }
    @discardableResult
    public func direction(_ direction: Direction) -> Self {
        view.layout.direction = direction
        view.setNeedsLayout()
        view.superview?.setNeedsLayout()
        return self
    }
    @discardableResult
    public func padding(all: CGFloat? = nil, top: CGFloat? = nil, left: CGFloat? = nil, bottom: CGFloat? = nil, right: CGFloat? = nil) -> Self {
        if let all = all {
            view.layout.padding = UIEdgeInsets(top: all, left: all, bottom: all, right: all)
        }
        if let top = top { view.layout.padding.top = top }
        if let left = left { view.layout.padding.left = left }
        if let bottom = bottom { view.layout.padding.bottom = bottom }
        if let right = right { view.layout.padding.right = right }
        view.setNeedsLayout()
        view.superview?.setNeedsLayout()
        return self
    }
    @discardableResult
    public func reverse(_ reverse: Bool) -> Self {
        view.layout.reverse = reverse
        view.setNeedsLayout()
        view.superview?.setNeedsLayout()
        return self
    }
}
