//
//  PropsInputView.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/5/23.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation


class PropsInputView: HBox, Stateful, Eventable, UITextFieldDelegate {
    struct ViewState {
        var title: String
        var value: CGFloat
    }

    let state = State(ViewState(title: "Props", value: 0))

    let emitter = SimpleIO<CGFloat>()

    override func buildBody() {
        attach {
            PropsTitleView().attach($0)
                .text(binder.title)
                .width(.fill)
                .textAlignment(.center)
                .margin(vert: 8)

            CGFloatInputView().attach($0)
                .state(binder.value)
                .onEvent(emitter)
                .size(.fill, .fill)
        }
        .space(4)
        .justifyContent(.center)
        .size(.fill, 30)
    }
}
