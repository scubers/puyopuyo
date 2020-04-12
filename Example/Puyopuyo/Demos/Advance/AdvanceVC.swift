//
//  AdvanceVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/12/8.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Puyopuyo
import UIKit

class AdvanceVC: BaseVC {
    override func configView() {
        DemoScroll(
            builder: {
                self.wrapPriority().attach($0)
                self.numberPad().attach($0)
                self.superviewRatio().attach($0)
                self.widthEqualToHeight().attach($0)
            }
        )
        .attach(vRoot)
        .attach {
            $0.delegate = self
        }
        .size(.fill, .fill)
    }

    func superviewRatio() -> UIView {
//        let aligment = State<SizeDescription>()
        return DemoView<Alignment>(
            title: "宽度为父view的0.8",
            builder: {
                HBox().attach($0) {
                    Label.demo("1").attach($0)
                        .height(40)
                        .width(on: $0) { .fix($0.width * 0.8) }
                }
                .space(2)
                .padding(all: 10)
                .justifyContent(.center)
                .size(.fill, 60)
                .animator(Animators.default)
                .view
            },
            selectors: [],
            desc: ""
        )
        .attach()
        .view
    }

    func widthEqualToHeight() -> UIView {
//        let aligment = State<SizeDescription>()
        return DemoView<Alignment>(
            title: "宽度等于高度",
            builder: {
                HBox().attach($0) {
                    Label.demo("1").attach($0)
                        .height(.fill)
                        .width(simulate: Simulate.ego.height)
                }
                .space(2)
                .padding(all: 10)
                .justifyContent(.center)
                .size(.fill, 60)
                .animator(Animators.default)
                .view
            },
            selectors: [],
            desc: ""
        )
        .attach()
        .view
    }

    func numberPad() -> UIView {
        DemoView<Alignment>(
            title: "数字键盘",
            builder: {
                VFlow(count: 3).attach($0) {
                    for i in 0 ..< 10 {
                        UILabel().attach($0)
                            .text((i + 1).description)
                            .size(.fill, .fill)
                            .textAlignment(.center)
                            .backgroundColor(Util.randomColor())
                    }
                }
                .space(4)
                .padding(all: 4)
                .size(.fill, 120)
                .view
            },
            selectors: [],
            desc: ""
        )
        .attach()
        .view
    }

    func wrapPriority() -> UIView {
        let text = State("")
        return DemoView<Alignment>(
            title: "wrap(priority:)",
            builder: {
                VBox().attach($0) {
                    HBox().attach($0) {
                        Label.demo("").attach($0)
                            .text(text)
                            .width(.wrap(priority: 2))

                        Label.demo("Will be compressed").attach($0)
                            .width(.wrap(priority: 1))
                            .height(.wrap(max: 20))

                        Label.demo("Will not compress").attach($0)
                            .width(.wrap(priority: 3))
                            .height(.wrap(max: 20))
                    }
                    .space(4)
                    .size(.fill, .wrap)

                    UITextField().attach($0)
                        .size(.fill, 30)
                        .texting(text)
                        .placeholder("please input something")
                }
                .padding(all: 4)
                .space(4)
                .size(.fill, .wrap)
                .view
            },
            selectors: [],
            desc: ""
        )
        .attach()
        .view
    }

    override func shouldRandomColor() -> Bool {
        return false
    }
}
