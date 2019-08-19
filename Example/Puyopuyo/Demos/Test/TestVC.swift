//
//  TestVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/8/18.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Puyopuyo

class TestVC: BaseVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        test1()
        
        randomViewColor(view: view)
    }
    
    private func test1() {
        vRoot.attach() {
            HBox().attach($0) {
                Label("正").attach($0)
                    .height(.fill)
                    .widthOnSelf({ .fixed($0.height) })
                
                Label("fill").attach($0)
                    .size(.fill, .fill)
                
                let v = $0
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    v.attach().height(200)
                    UIView.animate(withDuration: 0.2, animations: {
                        self.vRoot.layoutIfNeeded()
                    })
                })
            }
            .size(.fill, 100)
            .margin(all: 10)
            .padding(all: 10)
            
            let v = ZBox().attach($0) {
                
                let total = 10
                for idx in 0..<total {
                    UIView().attach($0)
                        .width(on: $0, { .fixed($0.width * (1 - CGFloat(idx) / CGFloat(total))) })
                        .height(on: $0, { .fixed($0.height * (1 - CGFloat(idx) / CGFloat(total))) })
                }
                
                
            }
            .width(.fill)
            .heightOnSelf({ .fixed($0.width * 0.5) })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                v.view.animate(0.25, block: {
                    v.heightOnSelf({ .fixed($0.width) })
                })
            })
            
            
            
        }
        .space(10)
    }
}
