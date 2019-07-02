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
    
    func setNeedsLayout() {
        view.setNeedsLayout()
        if let superview = view.superview as? BoxView {
            superview.setNeedsLayout()
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

extension PuyoLink: PuyoLinkAttacher where T: UIView {
    public typealias Holder = T
    public func attach(_ parent: UIView? = nil, wrap: Bool = false, _ block: PuyoLinkBlock? = nil) -> PuyoLink<T> {
        parent?.addSubview(view)
        block?(view)
        return self
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

extension PuyoLink where T: UIView {
    
    @discardableResult
    public func visible(_ visibility: Visiblity) -> Self {
        PuyoLinkHelper.visibility(for: view, visibility: visibility)
        return self
    }
    
    @discardableResult
    public func visible<S: Stateful>(_ visibility: S) -> Self where S.StateType == Visiblity {
        let unbinder = visibility.safeBind(view) { (v, visibility) in
            PuyoLinkHelper.visibility(for: v, visibility: visibility)
        }
        view.py_setUnbinder(unbinder, for: #function)
        return self
    }
    
    @discardableResult
    public func size(_ width: SizeDescription?, _ height: SizeDescription?) -> Self {
        PuyoLinkHelper.size(for: view, width: width, height: height)
        return self
    }
    
    @discardableResult
    public func size<S: Stateful>(_ width: S?, _ height: S?) -> Self where S.StateType == SizeDescription {
        if let width = width {
            view.py_setUnbinder(width.safeBind(view, { (v, w) in
                PuyoLinkHelper.size(for: v, width: w, height: nil)
            }), for: "\(#function)_width")
        }
        if let height = height {
            view.py_setUnbinder(height.safeBind(view, { (v, h) in
                PuyoLinkHelper.size(for: v, width: nil, height: h)
            }), for: "\(#function)_height")
        }
        return self
    }
    
    @discardableResult
    public func size(_ width: SizeDescriptible?, _ height: SizeDescriptible?) -> Self {
        PuyoLinkHelper.size(for: view, width: width?.sizeDescription, height: height?.sizeDescription)
        return self
    }
    
    @discardableResult
    public func size(_ width: SizeDescription?, _ height: SizeDescriptible?) -> Self {
        PuyoLinkHelper.size(for: view, width: width, height: height?.sizeDescription)
        return self
    }
    
    @discardableResult
    public func size(_ width: SizeDescriptible?, _ height: SizeDescription?) -> Self {
        PuyoLinkHelper.size(for: view, width: width?.sizeDescription, height: height)
        return self
    }
    
    @discardableResult
    public func width(_ width: SizeDescriptible?) -> Self {
        PuyoLinkHelper.size(for: view, width: width?.sizeDescription, height: nil)
        return self
    }
    
    @discardableResult
    public func width(_ width: SizeDescription?) -> Self {
        PuyoLinkHelper.size(for: view, width: width, height: nil)
        return self
    }
    
    @discardableResult
    public func width<S: Stateful>(_ width: S) -> Self where S.StateType == SizeDescription {
        return size(width, nil)
    }
    
    @discardableResult
    public func height(_ height: SizeDescriptible?) -> Self {
        PuyoLinkHelper.size(for: view, width: nil, height: height?.sizeDescription)
        return self
    }
    
    @discardableResult
    public func height(_ height: SizeDescription?) -> Self {
        PuyoLinkHelper.size(for: view, width: nil, height: height)
        return self
    }
    
    @discardableResult
    public func height<S: Stateful>(_ height: S) -> Self where S.StateType == SizeDescription {
        return size(nil, height)
    }
    
    @discardableResult
    public func margin(all: CGFloat? = nil, top: CGFloat? = nil, left: CGFloat? = nil, bottom: CGFloat? = nil, right: CGFloat? = nil) -> Self {
        PuyoLinkHelper.margin(for: view, all: all, top: top, left: left, bottom: bottom, right: right)
        return self
    }
    
    @discardableResult
    public func margin<S: Stateful>(_ margin: S) -> Self where S.StateType == UIEdgeInsets {
        let unbinder = margin.safeBind(view) { (v, m) in
            PuyoLinkHelper.margin(for: v, all: nil, top: m.top, left: m.left, bottom: m.bottom, right: m.right)
        }
        view.py_setUnbinder(unbinder, for: #function)
        return self
    }

    @discardableResult
    public func aligment(_ aligment: Aligment) -> Self {
        PuyoLinkHelper.aligment(for: view, aligment: aligment)
        return self
    }
    
    @discardableResult
    public func aligment<S: Stateful>(_ aligment: S) -> Self where S.StateType == Aligment {
        view.py_setUnbinder(aligment.safeBind(view, { (v, a) in
            PuyoLinkHelper.aligment(for: v, aligment: a)
        }), for: #function)
        return self
    }    
}

extension PuyoLink where T: BoxView {
    @discardableResult
    public func padding(all: CGFloat? = nil, top: CGFloat? = nil, left: CGFloat? = nil, bottom: CGFloat? = nil, right: CGFloat? = nil) -> Self {
        if let all = all {
            view.layout.padding = UIEdgeInsets(top: all, left: all, bottom: all, right: all)
        }
        if let top = top { view.layout.padding.top = top }
        if let left = left { view.layout.padding.left = left }
        if let bottom = bottom { view.layout.padding.bottom = bottom }
        if let right = right { view.layout.padding.right = right }
        setNeedsLayout()
        return self
    }
    
    @discardableResult
    public func padding<S: Stateful>(_ padding: S) -> Self where S.StateType == UIEdgeInsets {
        view.py_setUnbinder(padding.safeBind(view, { (v, i) in
            v.layout.padding = i
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func justifyContent(_ aligment: Aligment) -> Self {
        view.layout.justifyContent = aligment
        setNeedsLayout()
        return self
    }
    
    @discardableResult
    public func justifyContent<S: Stateful>(_ aligment: S) -> Self where S.StateType == Aligment {
        view.py_setUnbinder(aligment.safeBind(view, { (v, a) in
            v.layout.justifyContent = a
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
}

extension PuyoLink where T: FlatBox {
    
    @discardableResult
    public func space(_ space: CGFloat) -> Self {
        view.layout.space = space
        setNeedsLayout()
        return self
    }
    
    @discardableResult
    public func space<S: Stateful>(_ space: S) -> Self where S.StateType == CGFloat {
        view.py_setUnbinder(space.safeBind(view, { (v, s) in
            v.layout.space = s
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func formation(_ formation: Formation) -> Self {
        view.layout.formation = formation
        setNeedsLayout()
        return self
    }
    
    @discardableResult
    public func formation<S: Stateful>(_ formation: S) -> Self where S.StateType == Formation {
        view.py_setUnbinder(formation.safeBind(view, { (v, f) in
            v.layout.formation = f
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func direction(_ direction: Direction) -> Self {
        view.layout.direction = direction
        setNeedsLayout()
        return self
    }
    
    @discardableResult
    public func direction<S: Stateful>(_ direction: S) -> Self where S.StateType == Direction {
        view.py_setUnbinder(direction.safeBind(view, { (v, d) in
            v.layout.direction = d
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }

    @discardableResult
    public func reverse(_ reverse: Bool) -> Self {
        view.layout.reverse = reverse
        setNeedsLayout()
        return self
    }
    
    @discardableResult
    public func reverse<S: Stateful>(_ reverse: S) -> Self where S.StateType == Bool {
        view.py_setUnbinder(reverse.safeBind(view, { (v, r) in
            v.layout.reverse = r
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func autoJudgeScroll(_ judge: Bool) -> Self {
        view.layout.autoJudgeScroll = judge
        setNeedsLayout()
        return self
    }
}
