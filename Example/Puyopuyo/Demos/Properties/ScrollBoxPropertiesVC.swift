//
//  ScrollBoxPropertiesVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/12/15.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Puyopuyo
import UIKit

class ScrollBoxPropertiesVC: BaseVC {
    override func configView() {
        ScrollingBox<VBox> {
            for i in 0 ..< 100 {
                Label.demo("\(i)").attach($0)
                    .size(50, 50)
            }
        }
        .attach(vRoot)
        .scrollDirection(.y)
        .size(.fill, .fill)
        .margin(all: 10)
    }

    override func shouldRandomColor() -> Bool {
        true
    }
}
