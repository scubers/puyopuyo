//
//  PhoneViewController.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/6/5.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

class PhoneViewController: UIViewController {
    let store: BuilderStore
    init(store: BuilderStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder argument: NSCoder) {
        fatalError()
    }

    private var nav: UINavigationController!
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGroupedBackground

        let marginTop = State<CGFloat>(0)

        Outputs.listen(to: UIResponder.keyboardWillShowNotification).safeBind(to: self) { _, notice in
            if let frame = notice.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                marginTop.input(value: -frame.height)
            }
        }
        Outputs.listen(to: UIResponder.keyboardWillHideNotification).safeBind(to: self) { _, _ in
            marginTop.input(value: 0)
        }

        let moreSpace = State(false)

        VBox().attach(view) {
            CanvasPanel(store: store).attach($0)
                .width(.fill)
                .height(moreSpace.map { more -> SizeDescription in
                    more ? .aspectRatio(2 / 3) : .aspectRatio(3 / 2)
                })
                .margin(top: marginTop)

            HBox().attach($0) {
                UILabel().attach($0)
                    .text("More space")
                UISwitch().attach($0)
                    .isOn(moreSpace)
            }
            .padding(all: 4)
            .space(4)
            .justifyContent(.center)

            nav = UINavigationController(rootViewController: LayerPanelVC(store: store))
            nav.navigationBar.isTranslucent = false
            nav.isNavigationBarHidden = true
            addChild(nav)

            nav.view.attach($0)
                .size(.fill, .fill)
        }
        .animator(Animators.default)
        .padding(view.py_safeArea())
        .size(.fill, .fill)

        if store.root.value == nil {
            store.replaceRoot(store.buildWithJson(Helper.defaultViewJson))
        }
    }
}

private class LayerPanelVC: UIViewController {
    let store: BuilderStore
    init(store: BuilderStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder argument: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        store.selected.safeBind(to: self) { this, item in
            if item != nil, (this.navigationController?.viewControllers.count ?? 0) < 2 {
                this.navigationController?.setViewControllers([this, PropsPanelVC(store: this.store)], animated: true)
            }
            if item == nil {
                this.navigationController?.setViewControllers([this], animated: true)
            }
        }

        ZBox().attach(view) {
            LayerPanel(store: store).attach($0)
                .size(.fill, .fill)
        }
        .padding(view.py_safeArea())
        .size(.fill, .fill)
    }
}

private class PropsPanelVC: UIViewController {
    let store: BuilderStore
    init(store: BuilderStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder argument: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        VBox().attach(view) {
            HBox().attach($0) {
                UILabel().attach($0)
                    .text("< Back")
                    .textColor(UIColor.systemPink)
                    .userInteractionEnabled(true)
                    .onTap(to: self) { this, _ in
                        this.navigationController?.popViewController(animated: true)
                    }
            }
            .backgroundColor(.secondarySystemGroupedBackground)
            .width(.fill)
            .padding(all: 8)
            PropsPanel(store: store).attach($0)
                .size(.fill, .fill)
        }
        .padding(view.py_safeArea())
        .size(.fill, .fill)
    }

    deinit {
        store.selected.value = nil
    }
}
