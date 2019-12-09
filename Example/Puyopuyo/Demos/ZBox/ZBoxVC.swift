//
//  ZBoxVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/8/11.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Puyopuyo

class ZBoxVC: BaseVC {
    override func configView() {
        
        vRoot.attach() {
            
            ZBox().attach($0) {
                Label("left, top").attach($0)
                    .alignment([.left, .top])
                
                Label("right, top").attach($0)
                    .alignment([.right, .top])
                
                Label("left, bottom").attach($0)
                    .alignment([.left, .bottom])
                
                Label("right, bottom").attach($0)
                    .alignment([.right, .bottom])
                
                Label("right, center").attach($0)
                    .alignment([.right, .vertCenter])
                
                Label("left, center").attach($0)
                    .alignment([.left, .vertCenter])
                
                Label("center, top").attach($0)
                    .alignment([.horzCenter, .top])
                
                Label("center, bottom").attach($0)
                    .alignment([.horzCenter, .bottom])
                
                Label("center, center").attach($0)
                    .alignment([.center])
                
            }
            .padding(all: 10)
            .alignment(.center)
            .size(300, 300)
        }
        .format(.center)
    }
}
