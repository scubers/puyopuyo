//
//  AdvanceVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/12/8.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Puyopuyo
import UIKit

class AdvanceVC: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    
        DemoScroll(
            builder: {
                numberPad().attach($0)
                superviewRatio().attach($0)
            }
        )
        .attach(view)
        .size(.fill, .fill)
    }

    func superviewRatio() -> UIView {
//        let aligment = State<SizeDescription>()
        return DemoView<Alignment>(
            title: "Width is parent's 80%",
            builder: {
                HBox().attach($0) {
                    Label.demo("1").attach($0)
                        .height(40)
                        .width($0.py_boundsState().map { $0.width * 0.8 })
                }
                .space(2)
                .padding(all: 10)
                .justifyContent(.center)
                .size(.fill, 60)
                .animator(Animators.default)
            },
            selectors: [],
            desc: """
            All use the kvo's size will not correct calculate in on runloop
            """
        )
        .attach()
        .view
    }

    func numberPad() -> UIView {
        DemoView<Alignment>(
            title: "Number pad",
            builder: {
                VFlow(count: 3).attach($0) {
                    for i in 0 ..< 10 {
                        UILabel().attach($0)
                            .text((i + 1).description)
                            .size(.fill, .fill)
                            .textAlignment(.center)
                            .backgroundColor(Util.randomColor())
                            .userInteractionEnabled(true)
                            .style(TapTransformStyle())
                    }
                }
                .space(4)
                .padding(all: 4)
                .size(.fill, 240)
                .runRowSize(.fill)

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

            },
            selectors: [],
            desc: ""
        )
        .attach()
        .view
    }
}
