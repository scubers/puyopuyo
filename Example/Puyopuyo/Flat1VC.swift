//
//  Flat1VC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/6/30.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Puyopuyo

class Flat1VC: BaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        VBox.attach(view) {
            HBox.attach($0) {
                for idx in 0..<18 {
                    self.getView().attach($0)
                        .width({idx == 0 ? .ratio(1) : .fixed(10)}())
                        .height(10 * (idx + 1))
                }
            }
            .space(5)
            .size(.ratio(1), .wrap)
            .padding(all: 10)
            .justifyContent(.bottom)
            
            self.randomViewColor(view: $0)
        }
        .size(.ratio(1), .ratio(1))
    }
}
