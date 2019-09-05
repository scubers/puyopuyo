//
//  Puyo+ListBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/2.
//

import Foundation


extension Puyo where T: UIView {
    
    // MARK: - Size
    @discardableResult
    public func size(_ width: SizeDescription?, _ height: SizeDescription?) -> Self {
        PuyoHelper.size(for: view, width: width, height: height)
        return self
    }
    
    @discardableResult
    public func size<S: Outputing>(_ width: S?, _ height: S?) -> Self where S.OutputType == SizeDescription {
        if let width = width {
            view.py_setUnbinder(width.safeBind(view, { (v, w) in
                PuyoHelper.size(for: v, width: w, height: nil)
            }), for: "\(#function)_width")
        }
        if let height = height {
            view.py_setUnbinder(height.safeBind(view, { (v, h) in
                PuyoHelper.size(for: v, width: nil, height: h)
            }), for: "\(#function)_height")
        }
        return self
    }
    
    @discardableResult
    public func size(_ width: SizeDescriptible?, _ height: SizeDescriptible?) -> Self {
        PuyoHelper.size(for: view, width: width?.sizeDescription, height: height?.sizeDescription)
        return self
    }
    
    @discardableResult
    public func size(_ width: SizeDescription?, _ height: SizeDescriptible?) -> Self {
        PuyoHelper.size(for: view, width: width, height: height?.sizeDescription)
        return self
    }
    
    @discardableResult
    public func size(_ width: SizeDescriptible?, _ height: SizeDescription?) -> Self {
        PuyoHelper.size(for: view, width: width?.sizeDescription, height: height)
        return self
    }
    
    @discardableResult
    public func width(_ width: SizeDescriptible?) -> Self {
        PuyoHelper.size(for: view, width: width?.sizeDescription, height: nil)
        return self
    }
    
    @discardableResult
    public func width(_ width: SizeDescription?) -> Self {
        PuyoHelper.size(for: view, width: width, height: nil)
        return self
    }
    
    @discardableResult
    public func width<S: Outputing>(_ width: S) -> Self where S.OutputType == SizeDescription {
        return size(width, nil)
    }
    
    @discardableResult
    public func width(on view: UIView?, _ block: @escaping (CGRect) -> SizeDescription) -> Self {
        if let s = view?.py_boundsState() {
            return width(s.map(block))
        }
        return self
    }
    
    @discardableResult
    public func width(on modifiable: ValueModifiable) -> Self {
        return width(modifiable.checkSelfSimulate(view).modifyValue().map({ SizeDescription.fix($0)}))
    }
    
    @discardableResult
    public func widthOnSelf(_ block: @escaping (CGRect) -> SizeDescription) -> Self {
        return width(on: view, block)
    }
    
    @discardableResult
    public func height(_ height: SizeDescriptible?) -> Self {
        PuyoHelper.size(for: view, width: nil, height: height?.sizeDescription)
        return self
    }
    
    @discardableResult
    public func height(_ height: SizeDescription?) -> Self {
        PuyoHelper.size(for: view, width: nil, height: height)
        return self
    }
    
    @discardableResult
    public func height<S: Outputing>(_ height: S) -> Self where S.OutputType == SizeDescription {
        return size(nil, height)
    }
    
    @discardableResult
    public func height(on view: UIView?, _ block: @escaping (CGRect) -> SizeDescription) -> Self {
        if let s = view?.py_boundsState() {
            height(s.map(block))
        }
        return self
    }
    
    @discardableResult
    public func height(on modifiable: ValueModifiable) -> Self {
        return height(modifiable.checkSelfSimulate(view).modifyValue().map({ SizeDescription.fix($0) }))
    }
    
    @discardableResult
    public func heightOnSelf(_ block: @escaping (CGRect) -> SizeDescription) -> Self {
        return height(on: view, block)
    }
    
    // MARK: - Margin
    @discardableResult
    public func margin(all: CGFloat? = nil, top: CGFloat? = nil, left: CGFloat? = nil, bottom: CGFloat? = nil, right: CGFloat? = nil) -> Self {
        PuyoHelper.margin(for: view, all: all, top: top, left: left, bottom: bottom, right: right)
        return self
    }
    
    @discardableResult
    public func margin<S: Outputing>(all: S? = nil, top: S? = nil, left: S? = nil, bottom: S? = nil, right: S? = nil) -> Self where S.OutputType == CGFloat {
        if let s = all {
            view.py_setUnbinder(s.safeBind(view, { (v, a) in
                PuyoHelper.margin(for: v, all: a)
            }), for: "\(#function)_all")
        }
        if let s = top {
            view.py_setUnbinder(s.safeBind(view, { (v, a) in
                PuyoHelper.margin(for: v, top: a)
            }), for: "\(#function)_top")
        }
        if let s = left {
            view.py_setUnbinder(s.safeBind(view, { (v, a) in
                PuyoHelper.margin(for: v, left: a)
            }), for: "\(#function)_left")
        }
        if let s = bottom {
            view.py_setUnbinder(s.safeBind(view, { (v, a) in
                PuyoHelper.margin(for: v, bottom: a)
            }), for: "\(#function)_bottom")
        }
        if let s = right {
            view.py_setUnbinder(s.safeBind(view, { (v, a) in
                PuyoHelper.margin(for: v, right: a)
            }), for: "\(#function)_right")
        }
        return self
    }
    
    @discardableResult
    public func margin<S: Outputing>(_ margin: S) -> Self where S.OutputType == UIEdgeInsets {
        let unbinder = margin.safeBind(view) { (v, m) in
            PuyoHelper.margin(for: v, all: nil, top: m.top, left: m.left, bottom: m.bottom, right: m.right)
        }
        view.py_setUnbinder(unbinder, for: #function)
        return self
    }
    
    @discardableResult
    public func marginTop(on view: UIView?, _ block: @escaping (CGRect) -> CGFloat) -> Self {
        if let s = view?.py_boundsState() {
            margin(top: s.map(block))
        }
        return self
    }
    
    @discardableResult
    public func marginLeft(on view: UIView?, _ block: @escaping (CGRect) -> CGFloat) -> Self {
        if let s = view?.py_boundsState() {
            margin(left: s.map(block))
        }
        return self
    }
    
    @discardableResult
    public func marginBottom(on view: UIView?, _ block: @escaping (CGRect) -> CGFloat) -> Self {
        if let s = view?.py_boundsState() {
            margin(bottom: s.map(block))
        }
        return self
    }
    
    @discardableResult
    public func marginAll(on view: UIView?, _ block: @escaping (CGRect) -> CGFloat) -> Self {
        if let s = view?.py_boundsState() {
            margin(all: s.map(block))
        }
        return self
    }
    
    @discardableResult
    public func marginRight(on view: UIView?, _ block: @escaping (CGRect) -> CGFloat) -> Self {
        if let s = view?.py_boundsState() {
            margin(right: s.map(block))
        }
        return self
    }
    
    // MARK: - Aligment
    
    @discardableResult
    public func aligment(_ aligment: Aligment) -> Self {
        PuyoHelper.aligment(for: view, aligment: aligment)
        return self
    }
    
    @discardableResult
    public func aligment<S: Outputing>(_ aligment: S) -> Self where S.OutputType == Aligment {
        view.py_setUnbinder(aligment.safeBind(view, { (v, a) in
            PuyoHelper.aligment(for: v, aligment: a)
        }), for: #function)
        return self
    }
    
    // MARK: - Visibility
    @discardableResult
    public func control(_ control: Visibility) -> Self {
        view.py_visibility = control
        return self
    }
    
    @discardableResult
    public func control<S: Outputing>(_ control: S) -> Self where S.OutputType == Visibility {
        view.py_setUnbinder(control.safeBind(view, { (v, a) in
            v.py_visibility = a
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    // MARK: - Activated
    @discardableResult
    public func activated<S: Outputing>(_ activated: S) -> Self where S.OutputType == Bool {
        view.py_setUnbinder(activated.safeBind(view, { (v, a) in
            v.py_measure.activated = a
            v.py_setNeedsLayout()
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func activated(_ activated: Bool) -> Self {
        view.py_measure.activated = activated
        return self
    }
}
