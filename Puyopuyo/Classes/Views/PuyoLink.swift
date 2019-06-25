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
            view.py_measure.size = Size(main: .wrap, cross: .wrap)
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
    
    public func size(main: SizeType? = nil, cross: SizeType? = nil) -> Self {
        PuyoLinkHelper.size(for: view, main: main, cross: cross)
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
    
    public func xMargin(all: CGFloat? = nil, top: CGFloat? = nil, left: CGFloat? = nil, bottom: CGFloat? = nil, right: CGFloat? = nil) -> Self {
        PuyoLinkHelper.margin(for: view, all: all, top: top, left: left, bottom: bottom, right: right, direction: .x)
        return self
    }
    
    public func yMargin(all: CGFloat? = nil, top: CGFloat? = nil, left: CGFloat? = nil, bottom: CGFloat? = nil, right: CGFloat? = nil) -> Self {
        PuyoLinkHelper.margin(for: view, all: all, top: top, left: left, bottom: bottom, right: right, direction: .y)
        return self
    }
    
    public func vAligment(_ aligment: VAligment) -> Self {
        PuyoLinkHelper.vAligment(for: view, aligment: aligment)
        return self
    }
    
    public func hAligment(_ aligment: HAligment) -> Self {
        PuyoLinkHelper.hAligment(for: view, aligment: aligment)
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
    
    public func padding(all: CGFloat? = nil, start: CGFloat? = nil, end: CGFloat? = nil, forward: CGFloat? = nil, backward: CGFloat? = nil) -> Self {
        if let all = all {
            view.layout.padding = Edges(start: all, end: all, forward: all, backward: all)
        }
        if let start = start { view.layout.padding.start = start }
        if let end = end { view.layout.padding.end = end }
        if let forward = forward { view.layout.padding.forward = forward }
        if let backward = backward { view.layout.padding.backward = backward }
        return self
    }
    
    public func reverse(_ reverse: Bool) -> Self {
        view.layout.reverse = reverse
        return self
    }
}
