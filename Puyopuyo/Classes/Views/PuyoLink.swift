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
    
    public func visible(_ visibility: Visiblity) -> Self {
        PuyoLinkHelper.visibility(for: view, visibility: visibility)
        return self
    }
    
    public func size(width: SizeType? = nil, height: SizeType? = nil) -> Self {
        PuyoLinkHelper.size(for: view, width: width, height: height)
        return self
    }
    /*
    
    public func ySize(width: Sizable? = nil, height: Sizable? = nil) -> Self {
        PuyoLinkHelper.size(for: view, width: width, height: height, direction: .y)
        return self
    }
    
    public func xSize(width: Sizable? = nil, height: Sizable? = nil) -> Self {
        PuyoLinkHelper.size(for: view, width: width, height: height, direction: .x)
        return self
    }
    */
    
    public func margin(all: CGFloat? = nil, top: CGFloat? = nil, left: CGFloat? = nil, bottom: CGFloat? = nil, right: CGFloat? = nil) -> Self {
        PuyoLinkHelper.margin(for: view, all: all, top: top, left: left, bottom: bottom, right: right)
        return self
    }

    
    public func aligment(_ aligment: Aligment) -> Self {
        PuyoLinkHelper.aligment(for: view, aligment: aligment)
        return self
    }    
}

extension PuyoLink where T: Line {
    public func crossAxis(_ aligment: Aligment) -> Self {
        view.layout.crossAxis = aligment
        return self
    }
    
    public func space(_ space: CGFloat) -> Self {
        view.layout.space = space
        return self
    }
    
    public func formation(_ formation: Formation) -> Self {
        view.layout.formation = formation
        return self
    }
    
    public func direction(_ direction: Direction) -> Self {
        view.layout.direction = direction
        return self
    }
    
    public func padding(all: CGFloat? = nil, top: CGFloat? = nil, left: CGFloat? = nil, bottom: CGFloat? = nil, right: CGFloat? = nil) -> Self {
        if let all = all {
            view.layout.padding = UIEdgeInsets(top: all, left: all, bottom: all, right: all)
        }
        if let top = top { view.layout.padding.top = top }
        if let left = left { view.layout.padding.left = left }
        if let bottom = bottom { view.layout.padding.bottom = bottom }
        if let right = right { view.layout.padding.right = right }
        return self
    }
    
    public func reverse(_ reverse: Bool) -> Self {
        view.layout.reverse = reverse
        return self
    }
}
