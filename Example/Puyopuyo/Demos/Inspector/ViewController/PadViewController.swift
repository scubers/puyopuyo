//
//  ViewController.swift
//  PuyoBuilder
//
//  Created by Jrwong on 05/22/2022.
//  Copyright (c) 2022 Jrwong. All rights reserved.
//

import UIKit

class PadViewController: UIViewController {
    let store: BuilderStore
    init(store: BuilderStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGroupedBackground

        HBox().attach(view) {
            LayerPanel(store: store).attach($0)
                .size(240, .fill)

            CanvasPanel(store: store).attach($0)
                .size(.fill, .fill)

            PropsPanel(store: store).attach($0)
                .size(240, .fill)
        }
        .size(.fill, .fill)
        
        if store.root.value == nil {
            store.replaceRoot(store.buildWithJson(Helper.defaultViewJson))
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
}
