//
//  ZPropertiesVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/12/10.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Puyopuyo
import UIKit

class ZPropertiesVC: BaseVC {
    override func configView() {
        DemoScroll(
            builder: {
                self.alignment().attach($0)
            }
        )
        .attach(vRoot)
        .size(.fill, .fill)
    }

    func alignment() -> UIView {
        let alignment = State<Alignment>(.center)
        return DemoView<Alignment>(
            title: "alignment",
            builder: {
                ZBox().attach($0) {
                    Label.demo("demo").attach($0)
                        .alignment(alignment)
                }
                .padding(all: 8)
                .animator(Animators.default)
                .size(.fill, 100)
                .view
            },
            selectors: [Selector(desc: "left", value: .left),
                        Selector(desc: "right", value: .right),
                        Selector(desc: "top", value: .top),
                        Selector(desc: "bottom", value: .bottom),
                        Selector(desc: "center", value: .center),
                        Selector(desc: "top,left", value: [.top, .left]),
                        Selector(desc: "top,right", value: [.top, .right]),
                        Selector(desc: "top,horzCenter", value: [.top, .horzCenter]),
                        Selector(desc: "bottom,left", value: [.bottom, .left]),
                        Selector(desc: "bottom,right", value: [.bottom, .right]),
                        Selector(desc: "bottom,horzCenter", value: [.bottom, .horzCenter]),
                        Selector(desc: "left,vertCenter", value: [.left, .vertCenter]),
                        Selector(desc: "right,vertCenter", value: [.right, .vertCenter])],
            desc: "单个item在ZBox中的布局"
        )
        .attach()
        .onEventProduced(to: self, { _, x in
            alignment.value = x
        })
        .view
    }
}
