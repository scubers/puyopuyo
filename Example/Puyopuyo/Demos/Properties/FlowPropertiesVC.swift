//
//  FlowPropertiesVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/12/8.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Puyopuyo

class FlowPropertiesVC: BaseVC {
    override func configView() {
        
        DemoScroll(
            builder: {
                self.arrange().attach($0)
                self.reverse().attach($0)
            })
        .attach(vRoot)
        .size(.fill, .fill)
    }

    func arrange() -> UIView {
        let arrange = State<Int>(0)
        return DemoView<Int>(
            title: "arrange",
            builder: {
                self.getFlow().attach($0)
                    .arrangeCount(arrange)
                    .size(.fill, .wrap)
                    .view
            },
            selectors: (0..<10).map({ Selector(desc: "\($0)", value: $0)}),
            desc: "流式布局一行内的个数，0：代表自动计算换行")
            .attach()
            .onEventProduced(to: self, { (self, x) in
                arrange.value = x
            })
            .view
    }
    
    func reverse() -> UIView {
        let reverse = State<Bool>(false)
        return DemoView<Bool>(
            title: "reverse",
            builder: {
                self.getFlow().attach($0)
                    .arrangeCount(4)
                    .reverse(reverse)
                    .size(.fill, .wrap)
                    .view
            },
            selectors: [Selector(desc: "false", value: false),
                        Selector(desc: "true", value: true),
            ],
            desc: "")
            .attach()
            .onEventProduced(to: self, { (self, x) in
                reverse.value = x
            })
            .view
    }
    
    func getFlow() -> FlowBox {
        return
            VFlow().attach {
                for idx in 0..<10 {
                    Label.demo("\(idx + 1)").attach($0)
                        .size(40, 40)
                }
            }
            .space(2)
            .padding(all: 4)
            .view
    }
    
    override func shouldRandomColor() -> Bool {
        return false
    }
}
