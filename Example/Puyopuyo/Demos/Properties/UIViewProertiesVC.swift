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
                alignment().attach($0)
                crossSize().attach($0)
                mainSize().attach($0)
                visible().attach($0)
                margin().attach($0)
            }
        )
        .attach(vRoot)
        .size(.fill, .fill)
    }

    func visible() -> UIView {
        let a = State(Visibility.visible)
        return DemoView<Visibility>(
            title: "Visibility",
            builder: {
                HBox().attach($0) {
                    Label.demo("").attach($0)
                        .size(50, 50)

                    Label.demo("").attach($0)
                        .backgroundColor(.systemPink)
                        .visibility(a)
                        .size(60, 60)

                    Label.demo("").attach($0)
                        .size(50, 50)
                }
                .space(2)
                .padding(all: 10)
                .justifyContent(.center)
                .size(.fill, 100)
                .animator(Animators.default)

            },
            selectors: [
                Selector(desc: "Visible", value: .visible),
                Selector(desc: "invisible", value: .invisible),
                Selector(desc: "gone", value: .gone),
                Selector(desc: "free", value: .free),
            ],
            selected: a.value,
            desc: """
            visible: Calculate by boxview
            invisible: Calculate by boxview but view.isHidden = true
            gone: Will not be calculate, and view.isHidden = true
            free: Will not be calculate, and view.isHidden = false, you can set any frame as you want
            """
        )
        .attach()
        .onEvent(a)
        .view
    }

    func alignment() -> UIView {
        let a = State(Alignment.top)
        return DemoView<Alignment>(
            title: "Aligment",
            builder: {
                HBox().attach($0) {
                    Label.demo("top").attach($0)
                        .alignment(.top)
                    Label.demo("center").attach($0)
                        .alignment(.center)
                    Label.demo("bottom").attach($0)
                        .alignment(.bottom)

                    Label.demo("change").attach($0)
                        .alignment(a)
                        .backgroundColor(UIColor.systemPink)
                        .text(a.map(\.description))
                }
                .space(2)
                .padding(all: 10)
                .justifyContent(.center)
                .size(.fill, 100)
                .animator(Animators.default)

            },
            selectors: [
                Selector(desc: "top", value: .top),
                Selector(desc: "bottom", value: .bottom),
                Selector(desc: "center", value: .center),
                Selector(desc: "vertCenter(0.5)", value: .vertCenter(0.5)),
                Selector(desc: "vertCenter(-0.5)", value: .vertCenter(-0.5)),
            ],
            selected: a.value,
            desc: """
            Control self alignment in box, override the boxview's justifyContent
            """
        )
        .attach()
        .onEvent(a)
        .view
    }

    func crossSize() -> UIView {
        let s = State<SizeDescription>(.wrap)
        return DemoView<SizeDescription>(
            title: "cross size",
            builder: {
                VBox().attach($0) {
                    Label.demo(".fix(100)").attach($0)
                        .width(.fix(100))
                        .height(30)
                    Label.demo(".ratio(1)").attach($0)
                        .width(.ratio(1))
                        .height(30)
                    Label.demo(".wrap()").attach($0)
                        .width(.wrap)
                        .height(30)
                    Label.demo(".wrap(add: 10)").attach($0)
                        .width(.wrap(add: 10))
                        .height(30)
                    Label.demo(".wrap(add: 10, min: 20, max: 100)").attach($0)
                        .width(.wrap(add: 10, min: 20, max: 100))

                    Label.demo("change").attach($0)
                        .width(s)
                        .text(s.map(\.description))
                        .height(30)
                        .backgroundColor(UIColor.systemPink)
                }
                .space(8)
                .padding(all: 10)
                .size(.fill, .wrap)
                .animator(Animators.default)

            },
            selectors: [Selector(desc: ".wrap", value: .wrap),
                        Selector(desc: ".wrap(add(10))", value: .wrap(add: 10)),
                        Selector(desc: ".fix(50)", value: .fix(50)),
                        Selector(desc: ".ratio(1)", value: .ratio(1)),
                        Selector(desc: ".ratio(0.5)", value: .ratio(0.5))],
            selected: s.value,
            desc: """
            """
        )
        .attach()
        .onEvent(s)
        .view
    }

    func mainSize() -> UIView {
        let s = State<SizeDescription>(.wrap)
        return DemoView<SizeDescription>(
            title: "main size",
            builder: {
                VBox().attach($0) {
                    Label.demo(".fix(100)").attach($0)
                        .height(.fix(50))
                    Label.demo(".ratio(1)").attach($0)
                        .height(.ratio(1))
                    Label.demo(".ratio(2)").attach($0)
                        .height(.ratio(2))

                    Label.demo(".wrap()").attach($0)

                    Label.demo(".wrap(add: 10)").attach($0)
                        .height(.wrap(add: 10))
                    Label.demo(".wrap(add: 10, min: 40, max: 50)").attach($0)
                        .height(.wrap(add: 10, min: 40, max: 50))

                    Label.demo("change").attach($0)
                        .height(s)
                        .text(s.map(\.description))
                        .backgroundColor(UIColor.systemPink)
                }
                .space(8)
                .padding(all: 10)
                .size(.fill, 400)
                .animator(Animators.default)

            },
            selectors: [Selector(desc: ".wrap", value: .wrap),
                        Selector(desc: ".wrap(add(10))", value: .wrap(add: 10)),
                        Selector(desc: ".fix(50)", value: .fix(50)),
                        Selector(desc: ".ratio(1)", value: .ratio(1)),
                        Selector(desc: ".ratio(0.5)", value: .ratio(0.5))],
            selected: s.value,
            desc: """
            """
        )
        .attach()
        .onEvent(s)
        .view
    }

    func margin() -> UIView {
        let margin = State<CGFloat>(0)
        return DemoView<CGFloat>(
            title: "margin",
            builder: {
                HBox().attach($0) {
                    UIView().attach($0)
                        .size(.fill, .fill)
                        .style(StyleSheet.randomColorStyle)
                        .margin(margin.asOutput().map { UIEdgeInsets(top: $0, left: $0, bottom: $0, right: $0) })
                }
                .justifyContent(.center)
                .size(.fill, 100)
                .animator(Animators.default)
            },
            selectors: [0, 10, 20, 30, 40].map { Selector(desc: "\($0)", value: $0) },
            selected: margin.value,
            desc: "布局系统内，子view的外边局"
        )
        .attach()
        .onEvent(margin)
        .view
    }

    override func shouldRandomColor() -> Bool {
        return false
    }
}
