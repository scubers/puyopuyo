//
//  ZBoxSizeVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/8/11.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Puyopuyo

class ZBoxSizeVC: BaseVC {
    override func configView() {
        
        vRoot.attach() {
            UIScrollView().attach($0) {
                VBox().attach($0) {
                    
                    ZBox().attach($0) {
                        Label("over parent 20 point").attach($0)
                            .size(.fill, .fill)
                            .alignment(.center)
                            .margin(top: -20, left: -20)
                        }
                        .size(100, 100)
                    
                    HBox().attach($0) {
                        ZBox().attach($0) {
                            Label("20 point smaller").attach($0)
                                .size(.fill, .fill)
                                .alignment(.center)
                                .margin(top: 20, left: 20)
                            }
                            .size(100, 100)
                        
                        ZBox().attach($0) {
                            Label("20 point smaller").attach($0)
                                .size(.fill, .fill)
                                .alignment(.center)
                            }
                            .padding(top: 20, left: 20)
                            .size(100, 100)
                        }
                        .space(10)
                    
                    }
                    .space(20)
                    .size(.fill, .wrap)
                    .padding(all: 10)
                    .justifyContent(.center)
                }
                .alwaysVertBounds(true)
                .size(.fill, .fill)
        }
    }
}
