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
        RecycleBox(
            sections: [
                DataRecycleSection<(String, UIViewController.Type)>(
                    insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16),
                    lineSpacing: 16,
                    list: [
                        ("Test", TestVC.self),
                        ("TGVC", TGVC.self),
                        ("UIView Properties", UIViewProertiesVC.self),
                        ("FlatBox Properties", FlatPropertiesVC.self),
                        ("FlowBox Properties", FlowPropertiesVC.self),
                        ("ZBox Properties", ZPropertiesVC.self),
                        ("ScrollingBox Properties", ScrollBoxPropertiesVC.self),
                        ("NavigationBox Properties", NavigationBoxPropertiesVC.self),
                        ("RecycleBox Properties", RecycleBoxPropertiesVC.self),
                        ("SequenceBox Properties", SequenceBoxPropertiesVC.self),
                        ("TableBox Properties", TableBoxPropertiesVC.self),
                        ("CollectionBox Properties", CollectionBoxPropertiesVC.self),
                        ("Advance Usage", AdvanceVC.self),
                    ].asOutput(),
                    _cell: { o, _ in
                        HBox().attach {
                            Label("").attach($0)
                                .textAlignment(.left)
                                .text(o.map { $0.data.0 })
                        }
                        .size(.fill, .wrap)
                        .padding(all: 16)
                        .cornerRadius(8)
                        .backgroundColor(UIColor.white)
                        .view
                    },
                    _didSelect: { [weak self] c in
                        self?.push(vc: c.data.1.init())
                    }
                ),
            ].asOutput()
        )
        .attach(vRoot)
        .size(.fill, .fill)
        .backgroundColor(UIColor.lightGray.withAlphaComponent(0.5))

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
