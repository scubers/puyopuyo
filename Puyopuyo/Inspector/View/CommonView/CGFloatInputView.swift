//
//  CGFloatInputView.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/5/29.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

import UIKit

class CGFloatInputView: ZBox, Stateful, Eventable, UITextFieldDelegate {
    let state = State(CGFloat(0))
    let emitter = SimpleIO<CGFloat>()

    override func buildBody() {
        let text = State(value: "")

        let format = NumberFormatter()
        format.allowsFloats = true
        format.minimumIntegerDigits = 1
        format.maximumFractionDigits = 2
        format.minimumFractionDigits = 0
        state.distinct().safeBind(to: self) { _, value in
            text.value = format.string(from: NSNumber(value: value)) ?? "Nan"
        }

        let this = WeakableObject(value: self)

        attach {
            UITextField().attach($0)
                .text(text)
                .set(\.delegate, self)
                .onControlEvent(.editingChanged, Inputs {
                    let value = format.number(from: $0.text ?? "") ?? NSNumber(value: 0)
                    this.value?.emit(CGFloat(value.floatValue))
                })
                .size(.fill, .wrap(min: 30))
        }
        .padding(all: 4)
        .borderWidth(1)
        .cornerRadius(4)
        .clipToBounds(true)
        .borderColor(UIColor.separator)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
            return false
        }
        if string.isEmpty {
            return true
        }
        let result = string.trimmingCharacters(in: CharacterSet(charactersIn: "1234567890.").inverted)
        return result.count == string.count
    }
}
