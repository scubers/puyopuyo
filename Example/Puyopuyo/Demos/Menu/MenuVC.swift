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
    override func viewDidLoad() {
        super.viewDidLoad()

        DemoScroll(
            builder: {
                self.getCell(title: "UIView Properties", vc: UIViewProertiesVC.self).attach($0)
                self.getCell(title: "FlatBox Properties", vc: FlatPropertiesVC.self).attach($0)
                self.getCell(title: "FlowBox Properties", vc: FlowPropertiesVC.self).attach($0)
                self.getCell(title: "ZBox Properties", vc: ZPropertiesVC.self).attach($0)
                self.getCell(title: "Advance Usage", vc: AdvanceVC.self).attach($0)
            }
        )
        .attach(vRoot)
        .size(.fill, .fill)
    }

    func getCell(title: String, vc: UIViewController.Type) -> UIView {
        return HBox().attach {
            Label(title).attach($0)
                .textAlignment(.left)
                .size(.fill, .fill)
        }
        .size(.fill, 40)
        .onTap(to: self, { s, _ in
            s.push(vc: vc.init())
        })
        .bottomBorder([.color(Theme.dividerColor), .thick(0.5)])
        .view
    }

    func push(vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}
