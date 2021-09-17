//
//  ShowCaseVC.swift
//  Puyopuyo_Example
//
//  Created by J on 2021/9/17.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import Puyopuyo

class ShowCaseVC: BaseVC {
    override func configView() {
        DemoScroll { _ in
        }
        .attach(vRoot)
        .size(.fill, .fill)
    }
}
