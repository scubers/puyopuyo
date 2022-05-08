//
//  ScenesVC.swift
//  Puyopuyo_Example
//
//  Created by J on 2022/5/8.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import Puyopuyo

class ScenesVC: BaseViewController {
    let dataSrouce: [(String, () -> UIViewController)] = [
        ("News", { NewsVC() }),
    ]

    let isOn = State(false)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Scenes"

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: HBox().attach {
            UILabel().attach($0)
                .text("Present")
            UISwitch().attach($0)
                .isOn(isOn)
        }
        .justifyContent(.center)
        .space(4)
        .sizeControl(.bySet)
        .view)

        let this = WeakableObject(value: self)
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
        if isOn.value {
            present(vc, animated: true)
        } else {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
