//
//  AligmentVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/12/6.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Puyopuyo

class UIViewProertiesVC: BaseVC {

    override func configView() {
        
        DemoScroll(
            builder: {
                self.aligment().attach($0)
                self.size().attach($0)
                self.format().attach($0)
                self.margin().attach($0)
            })
        .attach(vRoot)
        .size(.fill, .fill)
    }
    
    func aligment() -> UIView {
        let aligment = State<Aligment>(.center)
        return DemoView<Aligment>(
            title: "UIView.AligmentSelf: 3",
            builder: {
                HBox().attach($0) {
                    Label.demo("1").attach($0)
                    Label.demo("2").attach($0)
                    Label.demo("3").attach($0)
                        .aligment(aligment)
                }
                .space(2)
                .padding(all: 10)
                .justifyContent(.center)
                .size(.fill, 60)
                .animator(Animators.default)
                .view
            },
            selectors: [Selector(desc: "top", value: .top),
                        Selector(desc: "bottom", value: .bottom),
                        Selector(desc: "center", value: .center)],
            desc: """
            覆盖Box.justfyContent, 单独设置自己的偏移
            """)
            .attach()
            .onEventProduced(to: self, { (self, x) in
                aligment.value = x
            })
            .view
    }
    
    func format() -> UIView {
        let format = State<Format>(.leading)
        return DemoView<Format>(
            title: "format",
            builder: {
                HBox().attach($0) {
                    Label.demo("1").attach($0)
                    Label.demo("2").attach($0)
                    Label.demo("3").attach($0)
                }
                .space(2)
                .padding(all: 10)
                .justifyContent(.center)
                .size(.fill, 60)
                .animator(Animators.default)
                .format(format)
                .view
            },
            selectors: [Selector(desc: "leading", value: .leading),
                         Selector(desc: "traing", value: .trailing),
                         Selector(desc: "center", value: .center),
                         Selector(desc: "avg", value: .avg),
                         Selector(desc: "sides", value: .sides),
            ],
            desc: "布局主轴上的格式")
            .attach()
            .onEventProduced(to: self, { (self, x) in
                format.value = x
            })
            .view
    }
    
    func size() -> UIView {
        let s = State<SizeDescription>(.wrap)
        return DemoView<SizeDescription>(
            title: "size",
            builder: {
                HBox().attach($0) {
                    Label.demo("1").attach($0)
                        .size(s, s)
                }
                .space(2)
                .padding(all: 10)
                .justifyContent(.center)
                .size(.fill, 60)
                .animator(Animators.default)
                .view
            },
            selectors: [Selector(desc: ".wrap", value: .wrap),
                         Selector(desc: ".wrap(add(10))", value: .wrap(add: 10)),
                         Selector(desc: ".fix(50)", value: .fix(50)),
                         Selector(desc: ".ratio(1)", value: .ratio(1)),
                         Selector(desc: ".ratio(0.5)", value: .ratio(0.5)),
            ],
            desc: """
            控制自身view的大小
            ratio: 占主轴上的比重（ratio / 主轴上的ratio之和）
            占次轴上的比例（1倍，0.5倍）
            """)
            .attach()
            .onEventProduced(to: self, { (self, x) in
                s.value = x
            })
            .view
    }
    
    func margin() -> UIView {
        let margin = State<CGFloat>(0)
        return DemoView<CGFloat>(
            title: "margin",
            builder: {
                HBox().attach($0) {
//                    Label.demo("1").attach($0)
//                    Label.demo("2").attach($0)
//                    Label.demo("3").attach($0)
                    UIView().attach($0)
                        .size(.fill, .fill)
                        .style(StyleSheet.randomColorStyle)
                        .margin(margin.asOutput().map({ UIEdgeInsets(top: $0, left: $0, bottom: $0, right: $0)}))
                }
                .justifyContent(.center)
                .size(.fill, 100)
                .animator(Animators.default)
                .view
            },
            selectors: [Selector(desc: "0", value: 0),
                         Selector(desc: "10", value: 10),
                         Selector(desc: "20", value: 20),
                         Selector(desc: "30", value: 30),
                         Selector(desc: "40", value: 40),
            ],
            desc: "布局系统内，子view的外边局")
            .attach()
            .onEventProduced(to: self, { (self, x) in
                margin.value = x
            })
            .view
    }
    
    override func shouldRandomColor() -> Bool {
        return false
    }
    
}
