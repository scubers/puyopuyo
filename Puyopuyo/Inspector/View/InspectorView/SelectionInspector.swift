//
//  SelectionInspector.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/5/23.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation


class SelectionInspector<V>: VBox, Stateful, Eventable {
    private let selection: [Selection<V>]
    let title: String
    init(title: String, selection: [Selection<V>]) {
        self.title = title
        self.selection = selection
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder argument: NSCoder) {
        fatalError()
    }

    let state = State(0)

    let emitter = SimpleIO<V>()

    override func buildBody() {
        let state = self.state
        attach {
            PropsSectionTitleView().attach($0)
                .text(title)
                .textAlignment(.left)
                .margin(vert: 8)
                .width(.fill)

            VFlowGroup().attach($0) {
                for (idx, selector) in selection.enumerated() {
                    SelectorButton().attach($0)
                        .setState(\.title, selector.title)
                        .setState(\.selected, state.distinct().map { $0 == idx })
                        .onTap(to: self) { this, _ in
                            state.value = idx
                            this.notify(index: idx)
                        }
                }
            }
            .space(4)
            .width(.fill)
        }
        .space(4)
        .width(.fill)
        .backgroundColor(.secondarySystemGroupedBackground)
        .padding(all: 8)
        .justifyContent(.center)
    }

    func notify(index: Int) {
        if index < selection.count {
            emit(selection[index].value)
        }
    }
}
