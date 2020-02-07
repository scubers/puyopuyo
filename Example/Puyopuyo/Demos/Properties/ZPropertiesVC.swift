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
                self.size().attach($0)
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

    func size() -> UIView {
        let size = State<SizeDescription>(.ratio(1))
        return DemoView<SizeDescription>(
            title: "size",
            builder: {
                ZBox().attach($0) {
                    ZBox().attach($0) {
                        Label.demo("demo").attach($0)
                            .alignment(.center)
                            .size(size, size)
                            .backgroundColor(Theme.color.withAlphaComponent(0.5))
                    }
                    .animator(Animators.default)
                    .backgroundColor(UIColor.black)
                    .size(100, 100)
                }
                .padding(all: 8)
                .animator(Animators.default)
                .size(.fill, 150)
                .view
            },
            selectors: [Selector(desc: ".ratio(1)", value: .ratio(1)),
                        Selector(desc: ".ratio(0.5)", value: .ratio(0.5)),
                        Selector(desc: ".ratio(1.5)", value: .ratio(1.5)),
                        Selector(desc: ".fix(60)", value: .fix(60)),
                        Selector(desc: ".wrap", value: .wrap),
                        Selector(desc: ".wrap(add: 10)", value: .wrap(add: 10)),
                        Selector(desc: ".fill", value: .fill)],
            desc: "Size 在ZBox中的体现形式"
        )
        .attach()
        .onEventProduced(to: self, { _, x in
            size.value = x
        })
        .view
    }
}
