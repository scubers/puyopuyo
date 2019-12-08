//
//  AdvanceVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/12/8.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Puyopuyo

class AdvanceVC: BaseVC {
    
    override func configView() {
            
        DemoScroll(
            builder: {
                self.superviewRatio().attach($0)
            })
        .attach(vRoot)
        .size(.fill, .fill)
    }
    
    func superviewRatio() -> UIView {
//        let aligment = State<SizeDescription>()
        return DemoView<Aligment>(
            title: "宽度为父view的0.8",
            builder: {
                HBox().attach($0) {
                    Label.demo("1").attach($0)
                        .height(40)
                        .width(on: $0, { .fix($0.width * 0.8)})
                }
                .space(2)
                .padding(all: 10)
                .justifyContent(.center)
                .size(.fill, 60)
                .animator(Animators.default)
                .view
            }, 
            selectors: [],
            desc: "")
            .attach()
            .view
    }
    
    override func shouldRandomColor() -> Bool {
        return false
    }

}
