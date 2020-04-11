//
//  VBoxVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/8/11.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Puyopuyo

class VBoxVC: BaseVC {
    override func configView() {
        
        navigationItem.title = "VBox,space=10,padding=10"
        UIScrollView().attach(vRoot) {
            
            VBox().attach($0) {
                Label("""
                    aligment = left
                    width = .wrap add 20
                    height = 100
                    """).attach($0)
                    .size(.wrap(add: 20), 100)
                    .styleSheet(.mainButton)
                
                Label("""
                    aligment = right
                    width = .wrap add 50
                    height = 200
                    """).attach($0)
                    .alignment(.right)
                    .size(.wrap(add: 50), 150)
                    .styleSheet(.mainButton)
                
                Label("""
                    aligment = center
                    width = .wrap add 80
                    height = wrap
                    """).attach($0)
                    .alignment(.center)
                    .size(.wrap(add: 80), .wrap)
                    .styleSheet(.mainButton)
                
                
                HBox().attach($0) {
                    Label("fix1").attach($0)
                        .size(50, 50)
                    Label("fix2").attach($0)
                        .size(60, 100)
                    
                    Label("fill").attach($0)
                        .margin(all: 10)
                        .size(.fill, .fill)
                    }
                    .space(10)
                    .justifyContent(.center)
                    .size(.fill, .wrap)
                    .borders([.thick(Util.pixel(1)), .color(.purple), .dash(3, 3)])
                    .styleSheet(.mainButton)
                
                
                }
                .space(10)
                .size(.fill, .wrap)
                .padding(all: 10)
                .margin(all: 10)
                .autoJudgeScroll(true)

            
            }
            .size(.fill, .fill)
    }
}
