//
//  PropsPanel.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/5/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation


class PropsPanel: ZBox {
    let store: BuilderStore
    init(store: BuilderStore) {
        self.store = store
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder argument: NSCoder) {
        fatalError()
    }

    override func buildBody() {
        let onChanged = SimpleIO<Void>()

        onChanged.debounce(interval: 0.5).dispatchMain().safeBind(to: self) { this, _ in
            this.store.record()
        }

        attach {
            UIScrollView().attach($0) {
                VBox().attach($0) {
                    store.selected.safeBind(to: $0) { vbox, id in
                        vbox.layoutChildren.forEach { $0.removeFromSuperBox() }

                        for state in id?.provider.states ?? [] {
                            if let view = InspectorViewFactory().createInspect(state, onChanged: onChanged) {
                                view.dislplayView.attach(vbox)
                                    .width(.fill)
                            }
                        }
                    }
                }
                .size(.fill, .wrap)
                .space(1)
                .autoJudgeScroll(true)
                .backgroundColor(UIColor.systemGroupedBackground)
            }
            .set(\.showsVerticalScrollIndicator, false)
            .size(.fill, .fill)
        }
        .backgroundColor(.secondarySystemGroupedBackground)
    }
}
