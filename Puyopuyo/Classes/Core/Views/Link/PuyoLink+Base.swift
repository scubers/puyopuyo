//
//  PuyoLink+ListBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/2.
//

import Foundation


extension PuyoLink where T: UIView {
    
    // MARK: - Size
    @discardableResult
    public func size(_ width: SizeDescription?, _ height: SizeDescription?) -> Self {
        PuyoLinkHelper.size(for: view, width: width, height: height)
        return self
    }
    
    @discardableResult
    public func size<S: Valuable>(_ width: S?, _ height: S?) -> Self where S.ValueType == SizeDescription {
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
    public func width<S: Valuable>(_ width: S) -> Self where S.ValueType == SizeDescription {
        return size(width, nil)
    }
    
    @discardableResult
    public func width(on view: UIView?, _ block: @escaping (CGRect) -> SizeDescription) -> Self {
        if let s = view?.py_observeBounds(block) {
            return width(s)
        }
        return self
    }
    
    @discardableResult
    public func width(_ modifiable: SizeModifiable) -> Self {
        return width(modifiable.modifySize())
    }
    
    @discardableResult
    public func widthOnSelf(_ block: @escaping (CGRect) -> SizeDescription) -> Self {
        return width(on: view, block)
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
    public func height<S: Valuable>(_ height: S) -> Self where S.ValueType == SizeDescription {
        return size(nil, height)
    }
    
    @discardableResult
    public func height(on view: UIView?, _ block: @escaping (CGRect) -> SizeDescription) -> Self {
        if let s = view?.py_observeBounds(block) {
            height(s)
        }
        return self
    }
    
    @discardableResult
    public func height(_ modifiable: SizeModifiable) -> Self {
        return height(modifiable.modifySize())
    }
    
    @discardableResult
    public func heightOnSelf(_ block: @escaping (CGRect) -> SizeDescription) -> Self {
        return height(on: view, block)
    }
    
    // MARK: - Margin
    @discardableResult
    public func margin(all: CGFloat? = nil, top: CGFloat? = nil, left: CGFloat? = nil, bottom: CGFloat? = nil, right: CGFloat? = nil) -> Self {
        PuyoLinkHelper.margin(for: view, all: all, top: top, left: left, bottom: bottom, right: right)
        return self
    }
    
    @discardableResult
    public func margin<S: Valuable>(all: S? = nil, top: S? = nil, left: S? = nil, bottom: S? = nil, right: S? = nil) -> Self where S.ValueType == CGFloat {
        if let s = all {
            view.py_setUnbinder(s.safeBind(view, { (v, a) in
                PuyoLinkHelper.margin(for: v, all: a)
            }), for: "\(#function)_all")
        }
        if let s = top {
            view.py_setUnbinder(s.safeBind(view, { (v, a) in
                PuyoLinkHelper.margin(for: v, top: a)
            }), for: "\(#function)_top")
        }
        if let s = left {
            view.py_setUnbinder(s.safeBind(view, { (v, a) in
                PuyoLinkHelper.margin(for: v, left: a)
            }), for: "\(#function)_left")
        }
        if let s = bottom {
            view.py_setUnbinder(s.safeBind(view, { (v, a) in
                PuyoLinkHelper.margin(for: v, bottom: a)
            }), for: "\(#function)_bottom")
        }
        if let s = right {
            view.py_setUnbinder(s.safeBind(view, { (v, a) in
                PuyoLinkHelper.margin(for: v, right: a)
            }), for: "\(#function)_right")
        }
        return self
    }
    
    @discardableResult
    public func margin<S: Valuable>(_ margin: S) -> Self where S.ValueType == UIEdgeInsets {
        let unbinder = margin.safeBind(view) { (v, m) in
            PuyoLinkHelper.margin(for: v, all: nil, top: m.top, left: m.left, bottom: m.bottom, right: m.right)
        }
        view.py_setUnbinder(unbinder, for: #function)
        return self
    }
    
    @discardableResult
    public func marginTop(on view: UIView?, _ block: @escaping (CGRect) -> CGFloat) -> Self {
        if let s = view?.py_observeBounds(block) {
            margin(top: s)
        }
        return self
    }
    
    @discardableResult
    public func marginLeft(on view: UIView?, _ block: @escaping (CGRect) -> CGFloat) -> Self {
        if let s = view?.py_observeBounds(block) {
            margin(left: s)
        }
        return self
    }
    
    @discardableResult
    public func marginBottom(on view: UIView?, _ block: @escaping (CGRect) -> CGFloat) -> Self {
        if let s = view?.py_observeBounds(block) {
            margin(bottom: s)
        }
        return self
    }
    
    @discardableResult
    public func marginAll(on view: UIView?, _ block: @escaping (CGRect) -> CGFloat) -> Self {
        if let s = view?.py_observeBounds(block) {
            margin(all: s)
        }
        return self
    }
    
    @discardableResult
    public func marginRight(on view: UIView?, _ block: @escaping (CGRect) -> CGFloat) -> Self {
        if let s = view?.py_observeBounds(block) {
            margin(right: s)
        }
        return self
    }
    
    // MARK: - Aligment
    
    @discardableResult
    public func aligment(_ aligment: Aligment) -> Self {
        PuyoLinkHelper.aligment(for: view, aligment: aligment)
        return self
    }
    
    @discardableResult
    public func aligment<S: Valuable>(_ aligment: S) -> Self where S.ValueType == Aligment {
        view.py_setUnbinder(aligment.safeBind(view, { (v, a) in
            PuyoLinkHelper.aligment(for: v, aligment: a)
        }), for: #function)
        return self
    }
    
    // MARK: - Visibility
    @discardableResult
    public func visible(_ visibility: Visiblity) -> Self {
        PuyoLinkHelper.visibility(for: view, visibility: visibility)
        return self
    }
    
    @discardableResult
    public func visible<S: Valuable>(_ visibility: S) -> Self where S.ValueType == Visiblity {
        view.py_setUnbinder(visibility.safeBind(view, { (v, a) in
            PuyoLinkHelper.visibility(for: v, visibility: a)
        }), for: #function)
        return self
    }
    
    // MARK: - Activated
    @discardableResult
    public func activated<S: Valuable>(_ activated: S) -> Self  where S.ValueType == Bool {
        view.py_setUnbinder(activated.safeBind(view, { (v, a) in
            v.py_measure.activated = a
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
}
