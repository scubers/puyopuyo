//
//  MenuViewController.swift
//  Puyopuyo_Example
//
//  Created by J on 2022/4/17.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Puyopuyo
import UIKit

class MenuViewController: BaseViewController {
    let dataSrouce: [(String, () -> UIViewController)] = [
        ("Test", { TestVC() }),
        ("Inspector", { InspectorFactory.createInsepectViewController() }),
        ("Scenes", { ScenesVC() }),
        ("UIView Properties", { UIViewProertiesVC() }),
        ("LinearBox Properties", { LinearPropertiesVC() }),
        ("Size Properties", { SizePropertiesVC() }),
        ("FlowBox Properties", { FlowPropertiesVC() }),
        ("ZBox Properties", { ZPropertiesVC() }),
        ("Scroll view", { ScrollVC() }),
        ("Animation", { AnimationVC() }),
        ("Style", { StyleVC() }),
        ("Chat", { ChatVC() }),
        ("Feed", { FeedVC() }),
        ("RecycleBox Properties", { RecycleBoxPropertiesVC() }),
        ("Advance Usage", { AdvanceVC() }),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Menu"

        let this = WeakableObject(value: self)

        let isOn = State(PuyoAppearence.semanticDirection == .rightToLeft)

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: IntrinsicSizeDelegateView {
            HBox().attach {
                UILabel().attach($0)
                    .text("RTL")
                UISwitch().attach($0)
                    .isOn(isOn)
            }
            .justifyContent(.center)
            .space(4)
        })

        isOn.skip(1).distinct().debounce().safeBind(to: self) { this, value in
            UIView.appearance().semanticContentAttribute = value ? .forceRightToLeft : .forceLeftToRight
            PuyoAppearence.semanticDirection = value ? .rightToLeft : .leftToRight
            this.navigationController?.setViewControllers([MenuViewController()], animated: true)
        }

        ZBox().attach(view) {
            RecycleBox(
                sections: [
                    ListRecycleSection(
                        insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16),
                        lineSpacing: 16,
                        items: dataSrouce.asOutput(),
                        cell: { o, i in
                            HBox().attach {
                                UILabel().attach($0)
                                    .textAlignment(.left)
                                    .text(o.data.0)
                            }
                            .cornerRadius(8)
                            .width(o.contentSize.width)
                            .padding(all: 16)
                            .styles([TapTransformStyle()])
                            .backgroundColor(.secondarySystemGroupedBackground)
                            .onTap {
                                i.inContext { c in
                                    let vc = c.data.1()
                                    vc.title = c.data.0
                                    this.value?.push(vc: vc)
                                }
                            }
                        }
                    ),
                ].asOutput()
            )
            .attach($0)
            .backgroundColor(.systemGroupedBackground)
            .size(.fill, .fill)
        }
        .size(.fill, .fill)
    }

    func push(vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}
