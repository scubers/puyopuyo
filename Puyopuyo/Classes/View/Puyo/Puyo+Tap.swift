//
//  Puyo+Tap.swift
//  Puyopuyo
//
//  Created by J on 2021/10/2.
//

import Foundation

public extension Puyo where T: UIView {
    @discardableResult
    func onTap<I: Inputing>(_ input: I) -> Self where I.InputType == UITapGestureRecognizer {
        view.py_addTap(action: {
            input.input(value: $0)
        })
        return self
    }

    @discardableResult
    func onTap<Object: AnyObject>(to object: Object?, _ action: @escaping (Object, UITapGestureRecognizer) -> Void) -> Self {
        onTap { [weak object] tap in
            if let o = object {
                action(o, tap)
            }
        }
    }

    @discardableResult
    func onTap(_ action: @escaping (UITapGestureRecognizer) -> Void) -> Self {
        onTap(Inputs(action))
    }

    @discardableResult
    func onTap(_ action: @escaping () -> Void) -> Self {
        onTap(Inputs { _ in
            action()
        })
    }
}
