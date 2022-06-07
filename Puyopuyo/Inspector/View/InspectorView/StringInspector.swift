//
//  CGFloatInspector.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/5/23.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation


class StringInspector: VBox, Stateful, Eventable {
    struct ViewState {
        var title: String
        var value: String
    }

    let state = State(ViewState(title: "", value: ""))
    let emitter = SimpleIO<String>()

    override func buildBody() {
        attach {
            PropsSectionTitleView().attach($0)
                .text(binder.title)
                .width(.fill)

            UITextField().attach($0)
                .text(binder.value.distinct())
                .onControlEvent(.editingChanged, emitter.asInput { $0.text ?? "" })
                .width(.fill)
                .height(.wrap(min: 30))
                .margin(all: 4)
                .borderWidth(1)
                .cornerRadius(4)
                .clipToBounds(true)
        }
        .width(.fill)
        .backgroundColor(.secondarySystemGroupedBackground)
        .space(4)
        .padding(all: 8)
    }
}
