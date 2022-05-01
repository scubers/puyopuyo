//
//  Puyo+ListBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/2.
//

import Foundation

// MARK: - Size ext

public extension Puyo where T: BoxLayoutNode & AutoDisposable {
    // MARK: - Width Height

    @discardableResult
    func width(_ width: SizeDescription) -> Self {
        set(\T.layoutMeasure.size.width, width)
    }

    @discardableResult
    func height(_ height: SizeDescription) -> Self {
        set(\T.layoutMeasure.size.height, height)
    }

    @discardableResult
    func width<O: Outputing>(_ w: O) -> Self where O.OutputType: SizeDescriptible {
        set(\T.layoutMeasure.size.width, w.asOutput().map(\.sizeDescription))
    }

    @discardableResult
    func height<O: Outputing>(_ h: O) -> Self where O.OutputType: SizeDescriptible {
        set(\T.layoutMeasure.size.height, h.asOutput().map(\.sizeDescription))
    }

    // MARK: - Size

    @discardableResult
    func size<O: Outputing>(_ w: O, _ h: O) -> Self where O.OutputType: SizeDescriptible {
        width(w).height(h)
    }

    @discardableResult
    func size(_ w: SizeDescription, _ h: SizeDescription) -> Self {
        width(w).height(h)
    }

    @discardableResult
    func size(_ w: SizeDescriptible, _ h: SizeDescription) -> Self {
        width(w.sizeDescription).height(h)
    }

    @discardableResult
    func size(_ w: SizeDescription, _ h: SizeDescriptible) -> Self {
        width(w).height(h.sizeDescription)
    }

    @discardableResult
    func size(_ size: Size) -> Self {
        set(\T.layoutMeasure.size, size)
    }

    @discardableResult
    func size<O: Outputing>(_ size: O) -> Self where O.OutputType == Size {
        set(\T.layoutMeasure.size, size)
    }

    // MARK: - Second layoutable methods

    /// Observe the given view's size to config view
    /// Due to use kvo, the size will not effect in one layout cycle.
    /// So it will take two layout cycle to get correct frame
    @discardableResult
    func width(on view: UIView?, _ block: @escaping (CGSize) -> SizeDescription) -> Self {
        if let s = view?.py_sizeState().distinct().dispatchMain() {
            return width(s.map(block).debounce())
        }
        return self
    }

    /// Observe the given view's size to config view
    /// Due to use kvo, the size will not effect in one layout cycle.
    /// So it will take two layout cycle to get correct frame
    @discardableResult
    func height(on view: UIView?, _ block: @escaping (CGSize) -> SizeDescription) -> Self {
        if let s = view?.py_sizeState().distinct().dispatchMain() {
            height(s.map(block).debounce())
        }
        return self
    }
}

// MARK: - Margin ext

public extension Puyo where T: BoxLayoutNode & AutoDisposable {
    @discardableResult
    func margin(all: CGFloatable? = nil,
                horz: CGFloatable? = nil,
                vert: CGFloatable? = nil,
                top: CGFloatable? = nil,
                left: CGFloatable? = nil,
                bottom: CGFloatable? = nil,
                right: CGFloatable? = nil) -> Self
    {
        PuyoHelper.margin(for: view.layoutMeasure, all: all?.cgFloatValue, horz: horz?.cgFloatValue, vert: vert?.cgFloatValue, top: top?.cgFloatValue, left: left?.cgFloatValue, bottom: bottom?.cgFloatValue, right: right?.cgFloatValue)
        return self
    }

    @discardableResult
    func margin<S: Outputing>(all: S? = nil, horz: S? = nil, vert: S? = nil, top: S? = nil, left: S? = nil, bottom: S? = nil, right: S? = nil) -> Self where S.OutputType: CGFloatable {
        if let s = all {
            doOn(s) { PuyoHelper.margin(for: $0.layoutMeasure, all: $1.cgFloatValue) }
        }
        if let s = top {
            doOn(s) { PuyoHelper.margin(for: $0.layoutMeasure, top: $1.cgFloatValue) }
        }
        if let s = horz {
            doOn(s) { PuyoHelper.margin(for: $0.layoutMeasure, horz: $1.cgFloatValue) }
        }
        if let s = vert {
            doOn(s) { PuyoHelper.margin(for: $0.layoutMeasure, vert: $1.cgFloatValue) }
        }
        if let s = left {
            doOn(s) { PuyoHelper.margin(for: $0.layoutMeasure, left: $1.cgFloatValue) }
        }
        if let s = bottom {
            doOn(s) { PuyoHelper.margin(for: $0.layoutMeasure, bottom: $1.cgFloatValue) }
        }
        if let s = right {
            doOn(s) { PuyoHelper.margin(for: $0.layoutMeasure, right: $1.cgFloatValue) }
        }
        return self
    }

    @discardableResult
    func margin<S: Outputing>(_ margin: S) -> Self where S.OutputType == UIEdgeInsets {
        set(\T.layoutMeasure.margin, margin)
    }
}

// MARK: - Alignment ext

public extension Puyo where T: BoxLayoutNode & AutoDisposable {
    @discardableResult
    func alignment(_ alignment: Alignment) -> Self {
        set(\T.layoutMeasure.alignment, alignment)
    }

    @discardableResult
    func alignment<S: Outputing>(_ alignment: S) -> Self where S.OutputType == Alignment {
        set(\T.layoutMeasure.alignment, alignment)
    }

    @discardableResult
    func flowEnding(_ flowEnding: Bool) -> Self {
        set(\T.layoutMeasure.flowEnding, flowEnding)
    }
}

// MARK: - Visibility

public extension Puyo where T: BoxLayoutNode & AutoDisposable {
    @discardableResult
    func visibility(_ visibility: Visibility) -> Self {
        set(\T.layoutVisibility, visibility)
    }

    @discardableResult
    func visibility<S: Outputing>(_ visibility: S) -> Self where S.OutputType == Visibility {
        set(\T.layoutVisibility, visibility)
    }
}

// MARK: - Activated

public extension Puyo where T: BoxLayoutNode & AutoDisposable {
    @discardableResult
    func activated<S: Outputing>(_ activated: S) -> Self where S.OutputType == Bool {
        set(\T.layoutMeasure.activated, activated)
    }
}

// MARK: - Animator

public extension Puyo where T: UIView {
    @discardableResult
    func animator(_ animator: Animator?) -> Self {
        set(\T.py_animator, animator)
    }

    @discardableResult
    func animator<O: Outputing>(_ animator: O) -> Self where O.OutputType: OptionalableValueType, O.OutputType.Wrap == Animator {
        set(\T.py_animator, animator.mapWrappedValue())
    }
}
