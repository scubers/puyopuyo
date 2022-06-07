//
//  View.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/5/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//


import UIKit

class CanvasView: ZBox {
    let store: BuilderStore

    init(store: BuilderStore) {
        self.store = store

        super.init(frame: .zero)

        buildCanvas()

        store.root.safeBind(to: self) { this, _ in
            this.buildCanvas()
        }

        attach().backgroundColor(.secondarySystemBackground)
            .size(store.canvasSize.map { Size(width: .fix($0.width), height: .fix($0.height)) })
            .animator(CanvasAnimator())
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    func buildCanvas() {
        layoutChildren.forEach { $0.removeFromSuperBox() }
        subviews.forEach { $0.removeFromSuperview() }
        if let node = store.buildRoot(), let view = node.layoutNodeView {
            addSubview(view)
        }
    }
}
