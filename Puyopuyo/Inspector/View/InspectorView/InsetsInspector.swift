//
//  InsetsInspector.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/5/23.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation


class InsetsInspector: VBox, Stateful, Eventable {
    struct ViewState {
        var title: String
        var insets: UIEdgeInsets
    }

    let state = State(ViewState(title: "", insets: .zero))

    let emitter = SimpleIO<UIEdgeInsets>()

    init(title: String = "") {
        super.init(frame: .zero)
        state.value.title = title
    }

    @available(*, unavailable)
    required init?(coder argument: NSCoder) {
        fatalError()
    }

    override func buildBody() {
        attach {
            PropsSectionTitleView().attach($0)
                .text(binder.title)
                .width(.fill)

            VFlow(count: 2).attach($0) {
                PropsInputView().attach($0)
                    .setState(\.title, "Top")
                    .setState(\.value, binder.insets.top.distinct())
                    .onEvent(to: self) { this, v in
                        this.notify(v, keyPath: \.insets.top)
                    }

                PropsInputView().attach($0)
                    .setState(\.title, "Left")
                    .setState(\.value, binder.insets.left.distinct())
                    .onEvent(to: self) { this, v in
                        this.notify(v, keyPath: \.insets.left)
                    }

                PropsInputView().attach($0)
                    .setState(\.title, "Bottom")
                    .setState(\.value, binder.insets.bottom.distinct())
                    .onEvent(to: self) { this, v in
                        this.notify(v, keyPath: \.insets.bottom)
                    }

                PropsInputView().attach($0)
                    .setState(\.title, "Right")
                    .setState(\.value, binder.insets.right.distinct())
                    .onEvent(to: self) { this, v in
                        this.notify(v, keyPath: \.insets.right)
                    }
            }
            .space(4)
            .width(.fill)
        }
        .justifyContent(.left)
        .padding(all: 8)
        .space(8)
        .backgroundColor(.secondarySystemGroupedBackground)
    }

    func notify<V>(_ value: V, keyPath: WritableKeyPath<ViewState, V>) {
        var state = self.state.value
        state[keyPath: keyPath] = value
        self.state.input(value: state)
        emit(state.insets)
    }
}
