//
//  SettingPannel.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/6/5.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation


class SettingPanel: VBox {
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
        let this = WeakableObject(value: self)
        attach {
            HGroup().attach($0) {
                PropsTitleView().attach($0)
                    .text("Colorize")

                UISwitch().attach($0)
                    .isOn(store.colorizeSetting)
            }
            .space(8)
            .justifyContent(.center)
            .width(.fill)

            HGroup().attach($0) {
                PropsInputView().attach($0)
                    .setState(\.title, "Width")
                    .setState(\.value, store.canvasSize.binder.width)
                    .onEvent(Inputs {
                        this.value?.store.setCanvasSize(width: $0)
                    })
                    .width(.fill)
                PropsInputView().attach($0)
                    .setState(\.title, "Height")
                    .setState(\.value, store.canvasSize.binder.height)
                    .onEvent(Inputs {
                        this.value?.store.setCanvasSize(height: $0)
                    })
                    .width(.fill)
            }
            .width(.fill)

            VFlow().attach($0) {
                SelectorButton().attach($0)
                    .state(.init(selected: false, title: "Export"))
                    .onTap(to: self) { this, _ in
                        if let json = this.store.exportJson(prettyPrinted: true) {
                            print(this.store.exportJson(prettyPrinted: false) ?? "")
                            findTopViewController(for: this)?.present(JsonViewVC(store: this.store, json: json), animated: true)
                        }
                    }
                SelectorButton().attach($0)
                    .state(.init(selected: false, title: "Import"))
                    .onTap(to: self) { this, _ in
                        findTopViewController(for: this)?.present(JsonViewVC(store: this.store, json: ""), animated: true)
                    }

                SelectorButton().attach($0)
                    .state(.init(selected: false, title: "Code"))
                    .onTap(to: self) { this, _ in
                        let json = this.store.exportCode()
                        print(this.store.exportJson(prettyPrinted: false) ?? "")
                        findTopViewController(for: this)?.present(JsonViewVC(store: this.store, json: json), animated: true)
                    }
            }
            .width(.fill)
            .space(8)
        }
        .width(200)
        .clipToBounds(true)
        .cornerRadius(6)
        .space(4)
        .padding(all: 8)
        .alignment([.top, .left])
        .backgroundColor(UIColor.secondarySystemGroupedBackground)
    }
}
