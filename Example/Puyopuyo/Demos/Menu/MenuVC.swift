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
    override var navTitle: String? {
        "MENU"
    }

//    override func loadView() {
//        view = UIView()
//
//        view.attach {
//            VBox().attach($0) { _ in
    ////                HBox().attach($0) {
    ////                    UILabel().attach($0)
    ////                        .text("124")
    ////                }
    ////                .size(.fill, 50)
//            }
//            .justifyContent(.center)
//            .padding(top: 100)
//            .size(.fill, .fill)
//        }
//    }
//
//    override func shouldRandomColor() -> Bool {
//        true
//    }

    override func configView() {
        menu()
    }

    let dataSrouce: [(String, () -> UIViewController)] = [
        ("Test", { TestVC() }),
        ("Feed", { FeedVC() }),
        ("UIView Properties", { UIViewProertiesVC() }),
        ("FlatBox Properties", { FlatPropertiesVC() }),
        ("FlowBox Properties", { FlowPropertiesVC() }),
        ("ZBox Properties", { ZPropertiesVC() }),
        ("ScrollingBox Properties", { ScrollBoxPropertiesVC() }),
        ("NavigationBox Properties", { NavigationBoxPropertiesVC() }),
        ("RecycleBox Properties", { RecycleBoxPropertiesVC() }),
        ("SequenceBox Properties", { SequenceBoxPropertiesVC() }),
        ("TableBox Properties", { TableBoxPropertiesVC() }),
        ("CollectionBox Properties", { CollectionBoxPropertiesVC() }),
        ("Advance Usage", { AdvanceVC() }),
    ]

    func menu() {
        let this = WeakCatcher(value: self)
        RecycleBox(
            sections: [
                DataRecycleSection<(String, () -> UIViewController)>(
                    insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16),
                    lineSpacing: 16,
                    items: dataSrouce.asOutput(),
                    cell: { o, i in
                        HBox().attach {
                            Label("").attach($0)
                                .textAlignment(.left)
                                .text(o.map(\.data.0))
                        }
                        .size(.fill, .wrap)
                        .padding(all: 16)
                        .backgroundColor(UIColor.white)
                        .styles([TapScaleStyle(), ShadowStyle()])
                        .onTap {
                            if let context = i.context {
                                this.value?.push(vc: context.data.1())
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
    }

    func push(vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension MenuVC: UITableViewDelegate {}
