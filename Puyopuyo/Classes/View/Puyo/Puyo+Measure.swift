//
//  Puyo+ListBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/2.
//

import Foundation

// MARK: - Size ext

public extension Puyo where T: UIView {
    @discardableResult
    func size<O: Outputing>(_ w: O?, _ h: O?) -> Self where O.OutputType: SizeDescriptible {
        if let x = w {
            x.safeBind(to: view, id: "\(#function)_width") { v, a in
                v.py_measure.size.width = a.sizeDescription
                v.py_setNeedsLayout()
            }
        }
        if let x = h {
            x.safeBind(to: view, id: "\(#function)_height") { v, a in
                v.py_measure.size.height = a.sizeDescription
                v.py_setNeedsLayout()
            }
        }
        return self
    }

    @discardableResult
    func width(_ width: SizeDescription) -> Self {
        return size(width, nil)
    }

    @discardableResult
    func height(_ height: SizeDescription) -> Self {
        return size(nil, height)
    }

    @discardableResult
    func width<O: Outputing>(_ w: O) -> Self where O.OutputType: SizeDescriptible {
        return size(w, nil)
    }

    @discardableResult
    func height<O: Outputing>(_ h: O) -> Self where O.OutputType: SizeDescriptible {
        return size(nil, h)
    }

    @discardableResult
    func size(_ w: SizeDescription, _ h: SizeDescription) -> Self {
        return width(w).height(h)
    }

    @discardableResult
    func size(_ w: SizeDescriptible, _ h: SizeDescription) -> Self {
        return width(w.sizeDescription).height(h)
    }

    @discardableResult
    func size(_ w: SizeDescription, _ h: SizeDescriptible) -> Self {
        return width(w).height(h.sizeDescription)
    }

    @discardableResult
    func width(on view: UIView?, _ block: @escaping (CGRect) -> SizeDescription) -> Self {
        if let s = view?.py_boundsState().distinct() {
            return width(s.map(block))
        }
        return self
    }

    @discardableResult
    func height(on view: UIView?, _ block: @escaping (CGRect) -> SizeDescription) -> Self {
        if let s = view?.py_boundsState().distinct() {
            height(s.map(block))
        }
        return self
    }

    @discardableResult
    func width(simulate modifiable: ValueModifiable) -> Self {
        return width(modifiable.checkSelfSimulate(view).modifyValue().map { SizeDescription.fix($0) })
    }

    @discardableResult
    func height(simulate modifiable: ValueModifiable) -> Self {
        return height(modifiable.checkSelfSimulate(view).modifyValue().map { SizeDescription.fix($0) })
    }
}

// MARK: - Margin ext

extension Puyo where T: UIView {
    @discardableResult
    public func margin(all: CGFloatable? = nil,
                       horz: CGFloatable? = nil,
                       vert: CGFloatable? = nil,
                       top: CGFloatable? = nil,
                       left: CGFloatable? = nil,
                       bottom: CGFloatable? = nil,
                       right: CGFloatable? = nil) -> Self {
        PuyoHelper.margin(for: view, all: all?.cgFloatValue, horz: horz?.cgFloatValue, vert: vert?.cgFloatValue, top: top?.cgFloatValue, left: left?.cgFloatValue, bottom: bottom?.cgFloatValue, right: right?.cgFloatValue)
        return self
    }

    @discardableResult
    public func margin<S: Outputing>(all: S? = nil, horz: S? = nil, vert: S? = nil, top: S? = nil, left: S? = nil, bottom: S? = nil, right: S? = nil) -> Self where S.OutputType: CGFloatable {
        if let s = all {
            view.py_setUnbinder(s.catchObject(view) { v, a in
                PuyoHelper.margin(for: v, all: a.cgFloatValue)
            }, for: "\(#function)_all")
        }
        if let s = top {
            view.py_setUnbinder(s.catchObject(view) { v, a in
                PuyoHelper.margin(for: v, top: a.cgFloatValue)
            }, for: "\(#function)_top")
        }
        if let s = horz {
            view.py_setUnbinder(s.catchObject(view) { v, a in
                PuyoHelper.margin(for: v, horz: a.cgFloatValue)
            }, for: "\(#function)_horz")
        }
        if let s = vert {
            view.py_setUnbinder(s.catchObject(view) { v, a in
                PuyoHelper.margin(for: v, vert: a.cgFloatValue)
            }, for: "\(#function)_vert")
        }
        if let s = left {
            view.py_setUnbinder(s.catchObject(view) { v, a in
                PuyoHelper.margin(for: v, left: a.cgFloatValue)
            }, for: "\(#function)_left")
        }
        if let s = bottom {
            view.py_setUnbinder(s.catchObject(view) { v, a in
                PuyoHelper.margin(for: v, bottom: a.cgFloatValue)
            }, for: "\(#function)_bottom")
        }
        if let s = right {
            view.py_setUnbinder(s.catchObject(view) { v, a in
                PuyoHelper.margin(for: v, right: a.cgFloatValue)
            }, for: "\(#function)_right")
        }
        return self
    }

    @discardableResult
    public func margin<S: Outputing>(_ margin: S) -> Self where S.OutputType == UIEdgeInsets {
        let unbinder = margin.catchObject(view) { v, m in
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
}

// MARK: - Alignment ext

public extension Puyo where T: UIView {
    @discardableResult
    func alignment(_ alignment: Alignment) -> Self {
        PuyoHelper.alignment(for: view, alignment: alignment)
        return self
    }

    @discardableResult
    func alignment<S: Outputing>(_ alignment: S) -> Self where S.OutputType == Alignment {
        view.py_setUnbinder(alignment.catchObject(view) { v, a in
            PuyoHelper.alignment(for: v, alignment: a)
        }, for: #function)
        return self
    }

    @discardableResult
    func alignmentRatio<O: Outputing>(horz: O? = nil, vert: O? = nil) -> Self where O.OutputType: CGFloatable {
        if let o = horz {
            o.safeBind(to: view, id: "\(#function)_horz") { v, a in
                v.py_measure.alignmentRatio.width = a.cgFloatValue
                v.py_setNeedsLayout()
            }
        }
        if let o = vert {
            o.safeBind(to: view, id: "\(#function)_vert") { v, a in
                v.py_measure.alignmentRatio.height = a.cgFloatValue
                v.py_setNeedsLayout()
            }
        }
        return self
    }
    
    @discardableResult
    func flowEnding(_ flowEnding: Bool) -> Self {
        view.py_measure.flowEnding = flowEnding
        setNeedsLayout()
        return self
    }

}

// MARK: - Visibility

extension Puyo where T: UIView {
    @discardableResult
    public func visibility(_ visibility: Visibility) -> Self {
        view.py_visibility = visibility
        view.py_setNeedsLayout()
        return self
    }

    @discardableResult
    public func visibility<S: Outputing>(_ visibility: S) -> Self where S.OutputType == Visibility {
        view.py_setUnbinder(visibility.catchObject(view) { v, a in
            v.py_visibility = a
            v.py_setNeedsLayout()
        }, for: #function)
        return self
    }
}

// MARK: - Activated

extension Puyo where T: UIView {
    @discardableResult
    public func activated<S: Outputing>(_ activated: S) -> Self where S.OutputType == Bool {
        view.py_setUnbinder(activated.catchObject(view) { v, a in
            v.py_measure.activated = a
            v.py_setNeedsLayout()
        }, for: #function)
        return self
    }
}
