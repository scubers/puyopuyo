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
        TableBox(
            sections: [
                TableSection<(String, UIViewController.Type), UIView, Void>(
                    identifier: "menu",
                    dataSource: State([
                        ("Test", TestVC.self),
                        ("TGVC", TGVC.self),
                        ("UIView Properties", UIViewProertiesVC.self),
                        ("FlatBox Properties", FlatPropertiesVC.self),
                        ("FlowBox Properties", FlowPropertiesVC.self),
                        ("ZBox Properties", ZPropertiesVC.self),
                        ("ScrollingBox Properties", ScrollBoxPropertiesVC.self),
                        ("NavigationBox Properties", NavigationBoxPropertiesVC.self),
                        ("TableBox Properties", TableBoxPropertiesVC.self),
                        ("CollectionBox Properties", CollectionBoxPropertiesVC.self),
                        ("Advance Usage", AdvanceVC.self),
                    ]).asOutput(),
                    _cell: { o, _ in
                        let padding: CGFloat = 16
                        return HBox().attach {
                            Label("").attach($0)
                                .textAlignment(.left)
                                .text(o.map { $0.data.0 })
                        }
                        .size(.fill, .wrap)
                        .padding(all: padding)
                        .view
                    },
                    _event: { [weak self] e in
                        switch e {
                        case let .didSelect(_, (_, vc)):
                            self?.push(vc: vc.init())
                        default: break
                        }
                    }
                ),
            ]
        )
        .attach(vRoot)
        .size(.fill, .fill)
        .setDelegate(self)

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
