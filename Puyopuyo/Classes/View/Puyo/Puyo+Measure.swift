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
            bind(keyPath: \T.py_measure.size.width, x.asOutput().map(\.sizeDescription))
        }
        if let x = h {
            bind(keyPath: \T.py_measure.size.height, x.asOutput().map(\.sizeDescription))
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
    func width(simulate modifiable: ValueModifiable) -> Self {
        return width(modifiable.checkSelfSimulate(view).modifyValue().map { SizeDescription.fix($0) })
    }

    @discardableResult
    func height(simulate modifiable: ValueModifiable) -> Self {
        return height(modifiable.checkSelfSimulate(view).modifyValue().map { SizeDescription.fix($0) })
    }
}

// MARK: - Margin ext

public extension Puyo where T: UIView {
    @discardableResult
    func margin(all: CGFloatable? = nil,
                horz: CGFloatable? = nil,
                vert: CGFloatable? = nil,
                top: CGFloatable? = nil,
                left: CGFloatable? = nil,
                bottom: CGFloatable? = nil,
                right: CGFloatable? = nil) -> Self
    {
        PuyoHelper.margin(for: view, all: all?.cgFloatValue, horz: horz?.cgFloatValue, vert: vert?.cgFloatValue, top: top?.cgFloatValue, left: left?.cgFloatValue, bottom: bottom?.cgFloatValue, right: right?.cgFloatValue)
        return self
    }

    @discardableResult
    func margin<S: Outputing>(all: S? = nil, horz: S? = nil, vert: S? = nil, top: S? = nil, left: S? = nil, bottom: S? = nil, right: S? = nil) -> Self where S.OutputType: CGFloatable {
        if let s = all {
            s.safeBind(to: view) { v, a in
                PuyoHelper.margin(for: v, all: a.cgFloatValue)
            }
        }
        if let s = top {
            s.safeBind(to: view) { v, a in
                PuyoHelper.margin(for: v, top: a.cgFloatValue)
            }
        }
        if let s = horz {
            s.safeBind(to: view) { v, a in
                PuyoHelper.margin(for: v, horz: a.cgFloatValue)
            }
        }
        if let s = vert {
            s.safeBind(to: view) { v, a in
                PuyoHelper.margin(for: v, vert: a.cgFloatValue)
            }
        }
        if let s = left {
            s.safeBind(to: view) { v, a in
                PuyoHelper.margin(for: v, left: a.cgFloatValue)
            }
        }
        if let s = bottom {
            s.safeBind(to: view) { v, a in
                PuyoHelper.margin(for: v, bottom: a.cgFloatValue)
            }
        }
        if let s = right {
            s.safeBind(to: view) { v, a in
                PuyoHelper.margin(for: v, right: a.cgFloatValue)
            }
        }
        return self
    }

    @discardableResult
    func margin<S: Outputing>(_ margin: S) -> Self where S.OutputType == UIEdgeInsets {
        bind(keyPath: \T.py_measure.margin, margin)
    }

    @discardableResult
    func marginTop(on view: UIView?, _ block: @escaping (CGRect) -> CGFloat) -> Self {
        if let s = view?.py_boundsState() {
            margin(top: s.map(block))
        }
        return self
    }

    @discardableResult
    func marginLeft(on view: UIView?, _ block: @escaping (CGRect) -> CGFloat) -> Self {
        if let s = view?.py_boundsState() {
            margin(left: s.map(block))
        }
        return self
    }

    @discardableResult
    func marginBottom(on view: UIView?, _ block: @escaping (CGRect) -> CGFloat) -> Self {
        if let s = view?.py_boundsState() {
            margin(bottom: s.map(block))
        }
        return self
    }

    @discardableResult
    func marginAll(on view: UIView?, _ block: @escaping (CGRect) -> CGFloat) -> Self {
        if let s = view?.py_boundsState() {
            margin(all: s.map(block))
        }
        return self
    }

    @discardableResult
    func marginRight(on view: UIView?, _ block: @escaping (CGRect) -> CGFloat) -> Self {
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
        bind(keyPath: \T.py_measure.alignment, alignment)
    }

    @discardableResult
    func alignmentRatio<O: Outputing>(horz: O? = nil, vert: O? = nil) -> Self where O.OutputType: CGFloatable {
        if let o = horz {
            bind(keyPath: \T.py_measure.alignmentRatio.width, o.mapCGFloat())
        }
        if let o = vert {
            bind(keyPath: \T.py_measure.alignmentRatio.height, o.mapCGFloat())
        }
        return self
    }

    @discardableResult
    func flowEnding(_ flowEnding: Bool) -> Self {
        bind(keyPath: \T.py_measure.flowEnding, flowEnding)
    }
}

// MARK: - Visibility

public extension Puyo where T: UIView {
    @discardableResult
    func visibility(_ visibility: Visibility) -> Self {
        bind(keyPath: \T.py_visibility, visibility)
    }

    @discardableResult
    func visibility<S: Outputing>(_ visibility: S) -> Self where S.OutputType == Visibility {
        bind(keyPath: \T.py_visibility, visibility)
    }
}

// MARK: - Activated

public extension Puyo where T: UIView {
    @discardableResult
    func activated<S: Outputing>(_ activated: S) -> Self where S.OutputType == Bool {
        bind(keyPath: \T.py_measure.activated, activated)
    }
}
