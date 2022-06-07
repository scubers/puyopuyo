//
//  BoolInspector.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/5/23.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation


class BoolInspector: HBox, Stateful, Eventable {
    struct ViewState {
        var title: String
        var value: Bool
    }

    let state = State(ViewState(title: "", value: false))
    let emitter = SimpleIO<Bool>()

    override func buildBody() {
        let this = WeakableObject(value: self)
        attach {
            PropsSectionTitleView().attach($0)
                .text(binder.title)
                .textAlignment(.center)
                .margin(vert: 8)

            UISwitch().attach($0)
                .set(\.isOn, binder.value)
                .onControlEvent(.valueChanged, Inputs {
                    this.value?.emit($0.isOn)
                })
        }
        .space(8)
        .width(.fill)
        .backgroundColor(.secondarySystemGroupedBackground)
        .padding(all: 8)
        .justifyContent(.center)
    }
}
