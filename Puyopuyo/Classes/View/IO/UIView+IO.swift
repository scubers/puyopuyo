//
//  UIView+IO.swift
//  Puyopuyo
//
//  Created by 王俊仁 on 2020/3/25.
//

import Foundation

public extension SimpleInput {
    static func keyPathInput<Root: AnyObject, Value>(object: Root, keypath: WritableKeyPath<Root, Value>) -> SimpleInput<Value> {
        SimpleInput<Value> { [weak object] in
            object?[keyPath: keypath] = $0
        }
    }
}

public extension UIView {
    func py_clipToBounds() -> SimpleInput<Bool> {
        .keyPathInput(object: self, keypath: \.clipsToBounds)
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

public extension UIButton {
    func py_click() -> SimpleOutput<UIButton> {
        py_event(.touchUpInside).map { $0 as! UIButton }
    }
}
