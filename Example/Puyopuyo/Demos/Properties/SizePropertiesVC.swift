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
                UILabel().attach($0)
                    .text("""
                    Rotate your device to landscape, get more space
                    """)
                    .fontSize(20, weight: .bold)
                    .numberOfLines(0)
                    .width(.fill)

                fixedSizeWillOverflow().attach($0)

                mainRatioSizeWillFillResidual().attach($0)
                crossRatioSizeWillOcuppyResidual().attach($0)

                wrapSizeWillBeCompress().attach($0)
                wrapSizePriority().attach($0)
                wrapSizeShrink().attach($0)
                wrapSizeGrow().attach($0)

                wrapSizeAddMinMax().attach($0)

                aspectRatio().attach($0)
                complexSize().attach($0)
            }
        )
        .attach(vRoot)
        .size(.fill, .fill)
    }

    func complexSize() -> UIView {
        let progress = State<CGFloat>(0.2)
        let content = progress.map { Int(50 * $0) }.map { (0 ..< $0).map(\.description).joined() }

        return DemoView<SizeDescription>(
            title: "Complex size demo",
            builder: {
                VBox().attach($0) {
                    HBox().attach($0) {
                        Label.demo("").attach($0)
                            .size(30, .fill)

                        Label.demo("").attach($0)
                            .width(.wrap(shrink: 1))
                            .text(content.map { "\($0)\($0)" })

                        Label.demo("").attach($0)
                            .text(content.map { "wrap(min: 50, shrink: 1)\n\($0)" })
                            .width(.wrap(max: 200, shrink: 1))
                            .height(.wrap(max: 100))
                            .aspectRatio(1 / 1)

                        Label.demo("cross\n.fill").attach($0)
                            .size(.wrap, .fill)

                        Label.demo("stay").attach($0)
                            .width(.wrap(priority: 2))
                    }
                    .demo()
                    .width(.fill)
                    .space(8)

                    UISlider().attach($0)
                        .bind(keyPath: \.value, progress.map(Float.init))
                        .onEvent(.valueChanged, progress.asInput { CGFloat($0.value) })
                        .width(.fill)
                }
                .width(.fill)
                .padding(all: 10)
            },
            selectors: [],
            desc: """
            1. w: 30, h: .fill
            2. w: wrap(shrink: 1), h: wrap
            3. w: wrap(max: 200, shrink: 1), h: wrap
            4. w: wrap, h: fill
            5. w: wrap(priority: 2), h: wrap
            """
        )
        .attach()
        .width(.fill)
        .view
    }

    func wrapSizeAddMinMax() -> UIView {
        let progress = State<CGFloat>(0.2)
        let content = progress.map { Int(50 * $0) }.map { (0 ..< $0).map(\.description).joined() }
        return DemoView<SizeDescription>(
            title: "Wrap size (add, min, max)",
            builder: {
                VBox().attach($0) {
                    HBox().attach($0) {
                        Label.demo("").attach($0)
                            .text(content.map { "wrap(max: 100)\n\($0)" })
                            .size(.wrap(max: 100), .wrap(max: 100))

                        Label.demo("").attach($0)
                            .text(content.map { "wrap(add: 50, shrink: 2)\n\($0)" })
                            .size(.wrap(add: 50, shrink: 2), .wrap(add: 50))

                        Label.demo("").attach($0)
                            .text(content.map { "min(100)\n\($0)" })
                            .size(.wrap(min: 100, shrink: 1), .wrap(min: 100))
                    }
                    .demo()
                    .width(.fill)
                    .space(8)

                    UISlider().attach($0)
                        .bind(keyPath: \.value, progress.map(Float.init))
                        .onEvent(.valueChanged, progress.asInput { CGFloat($0.value) })
                        .width(.fill)
                }
                .width(.fill)
                .padding(all: 10)
            },
            selectors: [],
            desc: """
            Wrap size add three another parameters to help control size.
            .wrap(add: min: max:)
            """
        )
        .attach()
        .width(.fill)
        .view
    }

    func aspectRatio() -> UIView {
        let progress = State<CGFloat>(0.5)
        let height = progress.map { 400 * $0 }
        return DemoView<SizeDescription>(
            title: "AspectRatio w / h",
            builder: {
                VBox().attach($0) {
                    HBox().attach($0) {
                        Label.demo("""
                        1 : 1
                        height(.fill)
                        """).attach($0)
                            .aspectRatio(1 / 1)
                            .height(.fill)

                        Label.demo("""
                        1 : 2
                        height(.wrap)
                        """).attach($0)
                            .aspectRatio(1 / 2)

                        Label.demo("""
                        2 : 1
                        height(.wrap)
                        """).attach($0)
                            .aspectRatio(2 / 1)

                        Label.demo("""
                        1 : 3
                        height(.fix(150))
                        """).attach($0)
                            .height(90)
                            .backgroundColor(.systemPink)
                            .aspectRatio(1 / 3)

                        Label.demo("""
                        1 : 100
                        fixed
                        """).attach($0)
                            .size(100, 100)
                            .aspectRatio(1 / 100)
                            .backgroundColor(.systemPink)
                    }
                    .demo()
                    .height(height.map { SizeDescription.fix($0) })
                    .width(.fill)
                    .space(8)

                    UILabel().attach($0)
                        .text(height.map {
                            "Height: \($0)"
                        })

                    UISlider().attach($0)
                        .bind(keyPath: \.value, progress.map(Float.init))
                        .onEvent(.valueChanged, progress.asInput { CGFloat($0.value) })
                        .width(.fill)
                }
                .width(.fill)
                .padding(all: 10)

            },
            selectors: [],
            desc: """
            AspectRatio means view's ratio value of width / height. It will not work if the size maybe fixed (width or height is fixed); Slide to change the height of box
            """
        )
        .attach()
        .width(.fill)
        .view
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
                    .width(Outputs.combine($0.py_boundsState().debounce(), progress).map { r, v -> SizeDescription in
                        .fix(r.width * v)
                    })
                    .height(80)
                    .space(8)

                    UISlider().attach($0)
                        .bind(keyPath: \.value, progress.map(Float.init))
                        .onEvent(.valueChanged, progress.asInput { CGFloat($0.value) })
                        .width(.fill)
                }
                .width(.fill)
                .padding(all: 10)
            },
            selectors: [],
            desc: """
            Wrap size will be compressed when residual size is not enough, set shrink value make wrap size view can shrink by seprate the overflow value, if overflow size is 600, then shrink(3) will compress 300 px, shrink(2) will compress 200 px, shrink(1) will be 100 px.
            Shrink view maybe overflow out of the layout box, because of each view will shrink the overflow size, but some view is too small to shrink
            """
        )
        .attach()
        .width(.fill)
        .view
    }

    func wrapSizeGrow() -> UIView {
        let progress = State<CGFloat>(1)
        return DemoView<SizeDescription>(
            title: "Wrap size grow",
            builder: {
                VBox().attach($0) {
                    HBox().attach($0) {
                        Label.demo("g(1)").attach($0)
                            .numberOfLines(1)
                            .width(.wrap(shrink: 1, grow: 1))
                            .height(30)

                        Label.demo("g(2)").attach($0)
                            .width(.wrap(shrink: 1, grow: 2))
                            .numberOfLines(1)
                            .height(30)

                        Label.demo("g(3)").attach($0)
                            .width(.wrap(shrink: 1, grow: 3))
                            .numberOfLines(1)
                            .height(30)
                    }
                    .demo()
                    .width(Outputs.combine($0.py_boundsState().debounce(), progress).map { r, v -> SizeDescription in
                        .fix(r.width * v)
                    })
                    .height(80)
                    .space(8)

                    UISlider().attach($0)
                        .bind(keyPath: \.value, progress.map(Float.init))
                        .onEvent(.valueChanged, progress.asInput { CGFloat($0.value) })
                        .width(.fill)
                }
                .width(.fill)
                .padding(all: 10)
            },
            selectors: [],
            desc: """
            Wrap size can be grew with the grow value, but it will not work when view has one or more main ratio sibling.
            Grow is the the other side with shrink, which will stretch the view to share the rest of the residual size.
            """
        )
        .attach()
        .width(.fill)
        .view
    }

    func wrapSizePriority() -> UIView {
        let progress = State(CGFloat(0.3))
        return DemoView<SizeDescription>(
            title: "Wrap size priority",
            builder: {
                VBox().attach($0) {
                    HBox().attach($0) {
                        Label.demo("change").attach($0)
                            .width(Outputs.combine($0.py_boundsState().debounce(), progress).map { r, v -> SizeDescription in
                                .fix(r.width * v)
                            })
                            .height(80)

                        Label.demo("priority(3)").attach($0)
                            .width(.wrap(priority: 3))
                            .height(80)

                        Label.demo("priority(2)").attach($0)
                            .width(.wrap(priority: 2))
                            .height(80)

                        Label.demo("priority(1)").attach($0)
                            .width(.wrap(priority: 1))
                            .height(80)

                        Label.demo("priority(2)").attach($0)
                            .width(.wrap(priority: 2))
                            .height(80)
                    }
                    .demo()
                    .padding(all: 10)
                    .margin(all: 10)
                    .width(.fill)
                    .space(8)

                    UISlider().attach($0)
                        .bind(keyPath: \.value, progress.map(Float.init))
                        .onEvent(.valueChanged, progress.asInput { CGFloat($0.value) })
                        .width(.fill)
                }
                .width(.fill)
                .padding(all: 10)

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
                    .width(Outputs.combine($0.py_boundsState().debounce(), progress).map { r, v -> SizeDescription in
                        .fix(r.width * v)
                    })
                    .space(8)

                    UISlider().attach($0)
                        .bind(keyPath: \.value, progress.map(Float.init))
                        .onEvent(.valueChanged, progress.asInput { CGFloat($0.value) })
                        .width(.fill)
                }
                .width(.fill)
                .padding(all: 10)

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

            },
            selectors: [],
            desc: ".ratio(value) size will fill up the residual size, if there are multiple ratio size, will separate by the ratio value. .fill == .ratio(1)"
        )
        .attach()
        .width(.fill)
        .view
    }

    func fixedSizeWillOverflow() -> UIView {
        let progress = State(CGFloat(1))
        return DemoView<CGFloat>(
            title: "Fixed size will overflow",
            builder: {
                VBox().attach($0) {
                    HBox().attach($0) {
                        for i in 0 ..< 10 {
                            Label.demo(i.description).attach($0)
                                .size(100, 100)
                        }
                    }
                    .demo()
                    .width(Outputs.combine($0.py_boundsState().debounce(), progress).map { r, v -> SizeDescription in
                        .fix(r.width * v)
                    })
                    .space(8)

                    UISlider().attach($0)
                        .bind(keyPath: \.value, progress.map(Float.init))
                        .onEvent(.valueChanged, progress.asInput { CGFloat($0.value) })
                        .width(.fill)
                }
                .width(.fill)
                .padding(all: 10)

            },
            selectors: [],
            desc: ".fixed(value) size will ignore residual size, and overflow"
        )
        .attach()
        .width(.fill)
        .view
    }
}
