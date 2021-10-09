//
//  MenuVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/6/30.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Puyopuyo
import UIKit

class MenuVC: BaseVC {
    override func configView() {
        menu()
    }

    let dataSrouce: [(String, () -> UIViewController)] = [
        ("Test", { TestVC() }),
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

    func menu() {
        let this = WeakableObject(value: self)
        RecycleBox(
            sections: [
                ListRecycleSection(
                    insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16),
                    lineSpacing: 16,
                    items: dataSrouce.asOutput(),
                    cell: { o, i in
                        HBox().attach {
                            Label("").attach($0)
                                .textAlignment(.left)
                                .text(o.map(\.data.0))
                        }
                        .width(o.contentSize.width)
                        .padding(all: 16)
                        .backgroundColor(UIColor.white)
                        .styles([TapTransformStyle(), ShadowStyle()])
                        .onTap {
                            i.inContext { c in
                                let vc = c.data.1()
                                vc.title = c.data.0
                                this.value?.push(vc: vc)
                            }
                        }
                        .view
                    }
                ),
            ].asOutput()
        )
        .attach(vRoot)
        .size(.fill, .fill)

        navState.value.bodyAvoidNavBar = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "MENU"
    }

    func push(vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension MenuVC: UITableViewDelegate {}
