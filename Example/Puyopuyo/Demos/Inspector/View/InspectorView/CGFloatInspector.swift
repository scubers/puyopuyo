//
//  CGFloatInspector.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/5/23.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation


class CGFloatInspector: VBox, Stateful, Eventable {
    struct ViewState {
        var title: String
        var value: CGFloat
    }

    let state = State(ViewState(title: "", value: 0))
    let emitter = SimpleIO<CGFloat>()

    override func buildBody() {
        attach {
            PropsSectionTitleView().attach($0)
                .text(binder.title)
                .width(.fill)

            CGFloatInputView().attach($0)
                .state(binder.value)
                .onEvent(emitter)
                .width(.fill)
        }
        .width(.fill)
        .backgroundColor(.secondarySystemGroupedBackground)
        .space(4)
        .padding(all: 8)
    }
}
