//
//  JsonViewVC.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/6/2.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

import UIKit

class JsonViewVC: UIViewController {
    init(store: BuilderStore, json: String) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
        self.text.input(value: json)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    let store: BuilderStore
    private let text = State("")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground

        VBox().attach(view) {
            HGroup().attach($0) {
                UIButton().attach($0)
                    .text("Close")
                    .onControlEvent(.touchUpInside, Inputs { [weak self] _ in
                        self?.dismiss(animated: true)
                    })

                SelectorButton().attach($0)
                    .state(.init(selected: false, title: "Import"))
                    .alignment(.right)
                    .onTap(to: self) { this, _ in
                        let store = this.store
                        let json = this.text.value

                        this.dismiss(animated: true) {
                            store.replaceRoot(store.buildWithJson(json))
                        }
                    }
            }
            .format(.between)
            .width(.fill)

            ZBox().attach($0) {
                UITextView().attach($0)
                    .onText(text)
                    .size(.fill, .fill)
            }
            .set(\.layer.borderWidth, 1)
            .set(\.layer.borderColor, UIColor.separator.cgColor)
            .cornerRadius(4)
            .padding(all: 4)
            .size(.fill, .fill)
        }
        .padding(all: 16)
        .space(8)
        .size(.fill, .fill)
    }
}
