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
        TableBox<(String, UIViewController.Type), UIView, Void>(
            cell: { o, _ in
                let padding: CGFloat = 16
                return HBox().attach {
                    Label("").attach($0)
                        .textAlignment(.left)
                        .text(o.map({ $0.0.0 }))
                }
                .size(.fill, .wrap)
                .padding(all: padding)
                .bottomBorder([.color(Theme.dividerColor), .thick(0.5), .lead(padding), .trail(padding)])
                .view
            }
        )
        .attach(vRoot)
        .viewState(State([[
            ("Test", TestVC.self),
            ("UIView Properties", UIViewProertiesVC.self),
            ("FlatBox Properties", FlatPropertiesVC.self),
            ("FlowBox Properties", FlowPropertiesVC.self),
            ("ZBox Properties", ZPropertiesVC.self),
            ("ScrollBox Properties", ScrollBoxPropertiesVC.self),
            ("NavigationBox Properties", NavigationBoxPropertiesVC.self),
            ("TableBox Properties", TableBoxPropertiesVC.self),
            ("Advance Usage", AdvanceVC.self),
        ]]))
        .onEventProduced(to: self, { s, e in
            s.push(vc: e.data.1.init())
        })
        .size(.fill, .fill)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func push(vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}
