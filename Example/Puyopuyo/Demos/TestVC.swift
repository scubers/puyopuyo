//
//  TestVC.swift
//  Puyopuyo_Example
//
//  Created by J on 2021/8/30.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Puyopuyo
import UIKit

class TestVC: BaseVC {
    override func configView() {
        VBox().attach(vRoot) {
            UILabel().attach($0)
                .text("100")
                .size(.ratio(1), .wrap)
        }
        .size(.fill, .wrap)
        .backgroundColor(UIColor.green)
    }
}
