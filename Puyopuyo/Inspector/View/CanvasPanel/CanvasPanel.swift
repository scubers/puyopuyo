//
//  CanvasPanel.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/5/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation


class CanvasPanel: ZBox {
    let store: BuilderStore
    init(store: BuilderStore) {
        self.store = store
        super.init(frame: .zero)

        attach()
            .justifyContent(.center)
            .padding(all: 20)
    }

    @available(*, unavailable)
    required init?(coder argument: NSCoder) {
        fatalError()
    }

    override func buildBody() {
        attach {
            CanvasView(store: store).attach($0) {
                store.colorizeSetting.safeBind(to: $0) { view, isOn in
                    if isOn {
                        view.colorizeSubviews { Helper.randomColor() }
                    } else {
                        view.colorizeSubviews { .clear }
                    }
                }
            }
        }
        .padding(py_safeArea().map { v in
            UIEdgeInsets(top: v.top + 8, left: v.left + 8, bottom: v.bottom + 8, right: v.right + 8)
        })
    }
}

extension UIView {
    func colorizeSubviews(_ color: () -> UIColor?) {
        subviews.forEach {
            $0.backgroundColor = color()
            $0.colorizeSubviews(color)
        }
    }
}
