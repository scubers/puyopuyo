//
//  Puyo+ListBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/2.
//

import Foundation

// MARK: - Size ext

public extension Puyo where T: UIView {
    // MARK: - Width Height

    @discardableResult
    func width(_ width: SizeDescription) -> Self {
        set(\T.py_measure.size.width, width)
    }

    @discardableResult
    func height(_ height: SizeDescription) -> Self {
        set(\T.py_measure.size.height, height)
    }

    @discardableResult
    func width<O: Outputing>(_ w: O) -> Self where O.OutputType: SizeDescriptible {
        set(\T.py_measure.size.width, w.asOutput().map(\.sizeDescription))
    }

    @discardableResult
    func height<O: Outputing>(_ h: O) -> Self where O.OutputType: SizeDescriptible {
        set(\T.py_measure.size.height, h.asOutput().map(\.sizeDescription))
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
        set(\T.py_measure.size, size)
    }

    @discardableResult
    func size<O: Outputing>(_ size: O) -> Self where O.OutputType == Size {
        set(\T.py_measure.size, size)
    }

    // MARK: - AspectRatio

//    @discardableResult
//    func aspectRatio(_ ratio: CGFloat?) -> Self {
//        set(\T.py_measure.size.aspectRatio, ratio)
//    }
//
//    @discardableResult
//    func aspectRatio<O: Outputing>(_ ratio: O) -> Self where O.OutputType: OptionalableValueType, O.OutputType.Wrap == CGFloat {
//        set(\T.py_measure.size.aspectRatio, ratio.mapWrappedValue())
//    }

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

    /// Observe the self's size to config view
    /// Due to use kvo, the size will not effect in one layout cycle.
    /// So it will take two layout cycle to get correct frame
    @discardableResult
    func widthEqualToHeight(add: CGFloat = 0, multiply: CGFloat = 1) -> Self {
        width(
            view.py_sizeState().map(\.height).map { v in
                multiply * v + add
            }
            .distinct()
            .map { SizeDescription.wrap(min: $0, max: $0) }
            .debounce()
        )
    }

    /// Observe the self's size to config view
    /// Due to use kvo, the size will not effect in one layout cycle.
    /// So it will take two layout cycle to get correct frame
    @discardableResult
    func heightEqualToWidth(add: CGFloat = 0, multiply: CGFloat = 1) -> Self {
        height(
            view.py_sizeState().map(\.width).map { v in
                multiply * v + add
            }
            .distinct()
            .map { SizeDescription.wrap(min: $0, max: $0) }
            .debounce()
        )
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
            doOn(s) { PuyoHelper.margin(for: $0, all: $1.cgFloatValue) }
        }
        if let s = top {
            doOn(s) { PuyoHelper.margin(for: $0, top: $1.cgFloatValue) }
        }
        if let s = horz {
            doOn(s) { PuyoHelper.margin(for: $0, horz: $1.cgFloatValue) }
        }
        if let s = vert {
            doOn(s) { PuyoHelper.margin(for: $0, vert: $1.cgFloatValue) }
        }
        if let s = left {
            doOn(s) { PuyoHelper.margin(for: $0, left: $1.cgFloatValue) }
        }
        if let s = bottom {
            doOn(s) { PuyoHelper.margin(for: $0, bottom: $1.cgFloatValue) }
        }
        if let s = right {
            doOn(s) { PuyoHelper.margin(for: $0, right: $1.cgFloatValue) }
        }
        return self
    }

    @discardableResult
    func margin<S: Outputing>(_ margin: S) -> Self where S.OutputType == UIEdgeInsets {
        set(\T.py_measure.margin, margin)
    }
}

// MARK: - Alignment ext

public extension Puyo where T: UIView {
    @discardableResult
    func alignment(_ alignment: Alignment) -> Self {
        set(\T.py_measure.alignment, alignment)
    }

    @discardableResult
    func alignment<S: Outputing>(_ alignment: S) -> Self where S.OutputType == Alignment {
        set(\T.py_measure.alignment, alignment)
    }

    @discardableResult
    func flowEnding(_ flowEnding: Bool) -> Self {
        set(\T.py_measure.flowEnding, flowEnding)
    }
}

// MARK: - Visibility

public extension Puyo where T: UIView {
    @discardableResult
    func visibility(_ visibility: Visibility) -> Self {
        set(\T.py_visibility, visibility)
    }

    @discardableResult
    func visibility<S: Outputing>(_ visibility: S) -> Self where S.OutputType == Visibility {
        set(\T.py_visibility, visibility)
    }
}

// MARK: - Activated

public extension Puyo where T: UIView {
    @discardableResult
    func activated<S: Outputing>(_ activated: S) -> Self where S.OutputType == Bool {
        set(\T.py_measure.activated, activated)
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
