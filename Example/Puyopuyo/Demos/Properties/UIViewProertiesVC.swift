//
//  AligmentVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/12/6.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Puyopuyo
import UIKit

class UIViewProertiesVC: BaseVC {
    override func configView() {
        DemoScroll(
            builder: {
                self.alignment().attach($0)
                self.size().attach($0)
                self.margin().attach($0)
            }
        )
        .attach(vRoot)
        .size(.fill, .fill)
    }

    func alignment() -> UIView {
        let aligment = State<Alignment>(.center)
        return DemoView<Alignment>(
            title: "UIView.AlignmentSelf: 3",
            builder: {
                HBox().attach($0) {
                    Label.demo("1").attach($0)
                    Label.demo("2").attach($0)
                    Label.demo("3").attach($0)
                        .alignment(aligment)
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
            """
        )
        .attach()
        .onEventProduced(to: self) { _, x in
            aligment.value = x
        }
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
                    Label.demo("2").attach($0)
                        .size(40, 40)
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
                        Selector(desc: ".ratio(0.5)", value: .ratio(0.5))],
            desc: """
            控制自身view的大小
            ratio: 占主轴上剩余空间的比重（ratio / 主轴上的ratio之和）
            占次轴上占满
            """
        )
        .attach()
        .onEventProduced(to: self) { _, x in
            s.value = x
        }
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
                        .margin(margin.asOutput().map { UIEdgeInsets(top: $0, left: $0, bottom: $0, right: $0) })
                }
                .justifyContent(.center)
                .size(.fill, 100)
                .animator(Animators.default)
                .view
            },
            selectors: [0, 10, 20, 30, 40].map { Selector(desc: "\($0)", value: $0) },
            desc: "布局系统内，子view的外边局"
        )
        .attach()
        .onEventProduced(to: self) { _, x in
            margin.value = x
        }
        .view
    }

    override func shouldRandomColor() -> Bool {
        return false
    }
}
