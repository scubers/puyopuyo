//
//  Puyo+UIScrollView.swift
//  Puyopuyo
//
//  Created by Junren Wong on 2019/8/2.
//

import Foundation

public extension Puyo where T: UIScrollView {
    @discardableResult
    func bounces<O: Outputing>(_ value: O) -> Self where O.OutputType == Bool {
        value.safeBind(to: view, id: #function) { v, a in
            v.bounces = a
        }
        return self
    }

    @discardableResult
    func alwaysVertBounds<O: Outputing>(_ value: O) -> Self where O.OutputType == Bool {
        value.safeBind(to: view, id: #function) { v, a in
            v.alwaysBounceVertical = a
        }
        return self
    }

    @discardableResult
    func alwaysHorzBounds<O: Outputing>(_ value: O) -> Self where O.OutputType == Bool {
        value.safeBind(to: view, id: #function) { v, a in
            v.alwaysBounceHorizontal = a
        }
        return self
    }

    @discardableResult
    func scrollEnabled<O: Outputing>(_ value: O) -> Self where O.OutputType == Bool {
        value.safeBind(to: view, id: #function) { v, a in
            v.isScrollEnabled = a
        }
        return self
    }

    @discardableResult
    func showHorzIndicator<O: Outputing>(_ value: O) -> Self where O.OutputType == Bool {
        value.safeBind(to: view, id: #function) { v, a in
            v.showsHorizontalScrollIndicator = a
        }
        return self
    }

    @discardableResult
    func showVertIndicator<O: Outputing>(_ value: O) -> Self where O.OutputType == Bool {
        value.safeBind(to: view, id: #function) { v, a in
            v.showsVerticalScrollIndicator = a
        }
        return self
    }

    @discardableResult
    func pagingEnabled<O: Outputing>(_ value: O) -> Self where O.OutputType == Bool {
        value.safeBind(to: view, id: #function) { v, a in
            v.isPagingEnabled = a
        }
        return self
    }

    @discardableResult
    func contentInsets(all: CGFloat? = nil, top: CGFloat? = nil, left: CGFloat? = nil, bottom: CGFloat? = nil, right: CGFloat? = nil) -> Self {
        if let v = all { view.contentInset = UIEdgeInsets(top: v, left: v, bottom: v, right: v) }
        if let v = top { view.contentInset.top = v }
        if let v = left { view.contentInset.right = v }
        if let v = bottom { view.contentInset.bottom = v }
        if let v = right { view.contentInset.right = v }
        return self
    }

    @discardableResult
    func contentOffset(x: CGFloat? = nil, y: CGFloat? = nil) -> Self {
        if let v = x { view.contentOffset.x = v }
        if let v = y { view.contentOffset.y = v }
        return self
    }

    @discardableResult
    func contentSize(width: CGFloat? = nil, height: CGFloat? = nil) -> Self {
        if let v = width { view.contentSize.width = v }
        if let v = height { view.contentSize.height = v }
        return self
    }

    @discardableResult
    func onContentOffsetChanged<T: Inputing>(_ input: T) -> Self where T.InputType == CGPoint {
        view.py_observing(for: #keyPath(UIScrollView.contentOffset))
            .map { (x: CGPoint?) in x ?? .zero }
            .distinct()
            .safeBind(to: view) {
                input.input(value: $1)
            }
        return self
    }

    @discardableResult
    func onContentSizeChanged<T: Inputing>(_ input: T) -> Self where T.InputType == CGSize {
        view.py_observing(for: #keyPath(UIScrollView.contentOffset))
            .map { (x: CGSize?) in x ?? .zero }
            .distinct()
            .safeBind(to: view) {
                input.input(value: $1)
            }
        return self
    }

    @discardableResult
    func flatBox(_ direction: Direction) -> Puyo<FlatBox> {
        if direction == .y {
            view.attach().alwaysVertBounds(true)
            return
                FlatBox().attach(view)
                    .direction(direction)
                    .autoJudgeScroll(true)
                    .size(.fill, .wrap)
        } else {
            view.attach().alwaysHorzBounds(true)
            return
                FlatBox().attach(view)
                    .direction(direction)
                    .autoJudgeScroll(true)
                    .size(.wrap, .fill)
        }
    }
}
