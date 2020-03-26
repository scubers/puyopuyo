//
//  UIView+IO.swift
//  Puyopuyo
//
//  Created by 王俊仁 on 2020/3/25.
//

import Foundation

public extension SimpleInput {
    static func keyPath<Root: AnyObject, Value>(object: Root, keypath: WritableKeyPath<Root, Value>) -> SimpleInput<Value> {
        SimpleInput<Value> { [weak object] in
            object?[keyPath: keypath] = $0
        }
    }
}

public extension UIControl {
    func py_event(_ event: UIControl.Event) -> SimpleOutput<UIControl> {
        SimpleOutput { i in
            self.py_addAction(for: event) {
                i.input(value: $0)
            }
        }
    }
}

public extension Outputing where OutputType: PuyoOptionalType {
    func mapWrappedValue() -> SimpleOutput<OutputType.PuyoWrappedType?> {
        asOutput().map { $0.puyoWrapValue }
    }
}

public extension Outputing where OutputType: CGFloatable {
    func mapCGFloat() -> SimpleOutput<CGFloat> {
        asOutput().map { $0.cgFloatValue }
    }
}
