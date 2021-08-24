//
//  UIView+IO.swift
//  Puyopuyo
//
//  Created by 王俊仁 on 2020/3/25.
//

import Foundation

public extension Inputs {
    static func keyPath<Root: AnyObject, Value>(object: Root, keypath: WritableKeyPath<Root, Value>) -> Inputs<Value> {
        Inputs<Value> { [weak object] in
            object?[keyPath: keypath] = $0
        }
    }
}

public extension UIControl {
    func py_event(_ event: UIControl.Event) -> Outputs<UIControl> {
        Outputs { i in
            self.py_addAction(for: event) {
                i.input(value: $0)
            }
        }
    }
}

public extension Outputing where OutputType: OptionalableValueType {
    func mapWrappedValue() -> Outputs<OutputType.Wrap?> {
        asOutput().map { $0.optionalValue }
    }
}

public extension Outputing where OutputType: CGFloatable {
    func mapCGFloat() -> Outputs<CGFloat> {
        asOutput().map { $0.cgFloatValue }
    }
}
