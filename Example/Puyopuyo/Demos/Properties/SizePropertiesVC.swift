//
//  SizePropertiesVC.swift
//  Puyopuyo_Example
//
//  Created by J on 2021/9/17.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import Puyopuyo

class SizePropertiesVC: BaseVC {
    override func configView() {
        DemoScroll(
            builder: {
                fixedSizeWillOverflow().attach($0)
                mainRatioSizeWillFillResidual().attach($0)
                crossRatioSizeWillOcuppyResidual().attach($0)
                wrapSizeWillBeCompress().attach($0)
                wrapSizePriority().attach($0)
                wrapSizeShrink().attach($0)
            }
        )
        .attach(vRoot)
        .size(.fill, .fill)
    }

    func wrapSizeShrink() -> UIView {
        let progress = State<CGFloat>(1)
        return DemoView<SizeDescription>(
            title: "Wrap size shrink",
            builder: {
                VBox().attach($0) {
                    HBox().attach($0) {
                        Label.demo("xxxxx shrink(3)").attach($0)
                            .numberOfLines(1)
                            .width(.wrap(shrink: 3))
                            .height(30)

                        Label.demo("yyyyy shrink(2)").attach($0)
                            .width(.wrap(shrink: 2))
                            .numberOfLines(1)
                            .height(30)

                        Label.demo("zzzzz shrink(1)").attach($0)
                            .width(.wrap(shrink: 1))
                            .numberOfLines(1)
                            .height(30)

                        Label.demo("aaaaa shrink(1)").attach($0)
                            .width(.wrap(shrink: 1))
                            .numberOfLines(1)
                            .height(30)
                    }
                    .demo()
                    .width(Outputs.combine($0.py_boundsState(), progress).map { r, v -> SizeDescription in
                        if v == 1 {
                            return .fill
                        } else {
                            return .fix(r.width * v)
                        }
                    })
                    .height(80)
                    .space(8)

                    UISlider().attach($0)
                        .bind(keyPath: \.value, progress.map(Float.init))
                        .onEvent(.valueChanged, progress.asInput { CGFloat($0.value) })
                        .width(.fill)
                }
                .width(.fill)
                .view
            },
            selectors: [],
            desc: "Wrap size will be compressed when residual size is not enough, set shrink value make wrap size view can shrink by seprate the overflow value, if overflow size is 600, then shrink(3) will compress 300 px, shrink(2) will compress 200 px, shrink(1) will be 100 px"
        )
        .attach()
        .width(.fill)
        .view
    }

    func wrapSizePriority() -> UIView {
//        let width = State(SizeDescription.fill)
        return DemoView<SizeDescription>(
            title: "Wrap size priority",
            builder: {
                VBox().attach($0) {
                    let text = State("")
//
                    UITextField().attach($0)
                        .onText(text)
                        .placeholder("Please input something here")
                        .size(.fill, 30)

                    HBox().attach($0) {
                        Label.demo("").attach($0)
                            .text(text)
                            .width(.wrap(priority: 3))

                        Label.demo("priority(1)").attach($0)
                            .width(.wrap(priority: 1))

                        Label.demo("priority(2)").attach($0)
                            .width(.wrap(priority: 2))
                    }
                    .demo()
                    .padding(all: 10)
                    .margin(all: 10)
                    .width(.fill)
                    .height(80)
                    .space(8)
                }
                .width(.fill)
                .view
            },
            selectors: [],
            desc: "Wrap has a priority value, wrap size will be compressed, priority is the value to control which view will be compressed first, the lower priority will be compressed first"
        )
        .attach()
        .width(.fill)
        .view
    }

    func wrapSizeWillBeCompress() -> UIView {
        let progress = State(CGFloat(1))
        return DemoView<SizeDescription>(
            title: "Wrap size",
            builder: {
                VBox().attach($0) {
                    HBox().attach($0) {
                        for _ in 0 ..< 10 {
                            Label.demo(Names().get()).attach($0)
                                .width(.wrap(add: 10))
                                .height(.wrap(add: 10))
                        }
                    }
                    .demo()
                    .width(Outputs.combine($0.py_boundsState(), progress).map { r, v -> SizeDescription in
                        if v == 1 {
                            return .fill
                        } else {
                            return .fix(r.width * v)
                        }
                    })
                    .space(8)

                    UISlider().attach($0)
                        .bind(keyPath: \.value, progress.map(Float.init))
                        .onEvent(.valueChanged, progress.asInput { CGFloat($0.value) })
                        .width(.fill)
                }
                .width(.fill)
                .view
            },
            selectors: [],
            desc: "Wrap size will wrap the content of the view, and calcaulate by the residual size, if residual size is smaller than content, view will be compress: There is 10 view above"
        )
        .attach()
        .width(.fill)
        .view
    }

    func crossRatioSizeWillOcuppyResidual() -> UIView {
        return DemoView<CGFloat>(
            title: "Cross ratio size",
            builder: {
                HBox().attach($0) {
                    Label.demo(".ratio(0.5)").attach($0)
                        .height(.ratio(0.5))
                    Label.demo(".ratio(1)").attach($0)
                        .height(.ratio(1))
                    Label.demo(".ratio(2)").attach($0)
                        .height(.ratio(2))
                }
                .demo()
                .width(.fill)
                .height(80)
                .space(8)
                .view
            },
            selectors: [],
            desc: "If cross size is ratio, the view will take the part of the residual size, if .ratio(1), will be residual * 1, .ratio(2) will be residual * 2"
        )
        .attach()
        .width(.fill)
        .view
    }

    func mainRatioSizeWillFillResidual() -> UIView {
        return DemoView<CGFloat>(
            title: "Main ratio size will fill up the residual size",
            builder: {
                HBox().attach($0) {
                    Label.demo(".ratio(1)").attach($0)
                        .width(.ratio(1))
                        .height(50)
                    Label.demo(".ratio(2)").attach($0)
                        .width(.ratio(2))
                        .height(50)
                    Label.demo(".ratio(3)").attach($0)
                        .width(.ratio(3))
                        .height(50)
                }
                .demo()
                .width(.fill)
                .space(8)
                .view
            },
            selectors: [],
            desc: ".ratio(value) size will fill up the residual size, if there are multiple ratio size, will separate by the ratio value. .fill == .ratio(1)"
        )
        .attach()
        .width(.fill)
        .view
    }

    func fixedSizeWillOverflow() -> UIView {
        return DemoView<CGFloat>(
            title: "Fixed size will overflow",
            builder: {
                HBox().attach($0) {
                    for i in 0 ..< 20 {
                        Label.demo(i.description).attach($0)
                            .size(100, 100)
                    }
                }
                .demo()
                .width(.fill)
                .space(8)
                .view
            },
            selectors: [],
            desc: ".fixed(value) size will ignore residual size, and overflow"
        )
        .attach()
        .width(.fill)
        .view
    }
}
