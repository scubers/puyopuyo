//
//  LinearPropertiesVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/12/8.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Puyopuyo
import UIKit

class LinearPropertiesVC: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        DemoScroll(
            builder: {
                direction().attach($0)
                format().attach($0)
                justifyContent().attach($0)
                activate().attach($0)
                space().attach($0)
                reverse().attach($0)
                padding().attach($0)
            }
        )
        .attach(view)
        .size(.fill, .fill)
    }

    func justifyContent() -> UIView {
        let justifyContent = State<Alignment>(.top)
        return DemoView<Alignment>(
            title: "justifyContent",
            builder: {
                HBox().attach($0) {
                    Label.demo("1").attach($0)
                    Label.demo("2").attach($0)
                    Label.demo("3").attach($0)
                }
                .space(2)
                .padding(all: 10)
                .justifyContent(justifyContent)
                .size(.fill, 100)
                .animator(Animators.default)

            },
            selectors: [
                Selector(desc: "top", value: .top),
                Selector(desc: "center", value: .center),
                Selector(desc: "bottom", value: .bottom),
            ],
            selected: justifyContent.value,
            desc: """
            Box.justfyContent, BoxViwe will adjust all subviews alignment at cross axis
            """
        )
        .attach()
        .onEvent(justifyContent)
        .view
    }

    func activate() -> UIView {
        let justifyContent = State<Alignment>(.top)
        return DemoView<Alignment>(
            title: "activate",
            builder: {
                HBox().attach($0) {
                    Label.demo("1").attach($0)
                        .frame(x: 0, y: 0, w: 20, h: 20)
                        .activated(false)
                    Label.demo("2").attach($0)
                    Label.demo("3").attach($0)
                }
                .space(2)
                .padding(all: 10)
                .justifyContent(justifyContent)
                .size(.fill, 100)
                .animator(Animators.default)
            },
            selectors: [
                Selector(desc: "top", value: .top),
                Selector(desc: "center", value: .center),
                Selector(desc: "bottom", value: .bottom),
            ],
            selected: justifyContent.value,
            desc: """
            if measure.activate = false, the view will not be calculate by box, you can set frame to position it.
            """
        )
        .attach()
        .onEvent(justifyContent)
        .view
    }

    func format() -> UIView {
        let format = State<Format>(.leading)
        return DemoView<Format>(
            title: "format",
            builder: {
                HBox().attach($0) {
                    for _ in 0 ..< 5 {
                        Label.demo("").attach($0)
                            .size(40, 40)
                    }

                    UIView().attach($0)
                        .activated(false)
                        .backgroundColor(UIColor.label)
                        .set(\.center, $0.py_boundsState().map { CGPoint(x: $0.width / 2, y: $0.height / 2) })
                        .set(\.frame.size.height, $0.py_boundsState().map { $0.height })
                        .frame(w: 1)
                }
                .space(10)
                .padding(all: 10)
                .justifyContent(.center)
                .size(.fill, 60)
                .animator(Animators.default)
                .format(format)

            },
            selectors: [
                Selector(desc: "leading", value: .leading),
                Selector(desc: "between", value: .between),
                Selector(desc: "center", value: .center),
                Selector(desc: "round", value: .round),
                Selector(desc: "trailing", value: .trailing),
            ],
            selected: format.value,
            desc: "All subviews formation at main axis"
        )
        .attach()
        .onEvent(format)
        .view
    }

    func direction() -> UIView {
        let direction = State<Direction>(.x)
        return DemoView<Direction>(
            title: "direction",
            builder: {
                LinearBox().attach($0) {
                    Label.demo("1").attach($0)
                    Label.demo("2").attach($0)
                    Label.demo("3").attach($0)
                }
                .space(2)
                .padding(all: 10)
                .justifyContent(.center)
                .size(.fill, .wrap)
                .animator(Animators.default)
                .direction(direction)

            },
            selectors: [
                Selector(desc: "x", value: .x),
                Selector(desc: "y", value: .y),
            ],
            selected: direction.value,
            desc: """
            x: Horizontal
            y: Vertical
            """
        )
        .attach()
        .onEvent(direction)
        .view
    }

    func padding() -> UIView {
        let padding = State<CGFloat>(0)
        return DemoView<CGFloat>(
            title: "padding",
            builder: {
                HBox().attach($0) {
                    UIView().attach($0)
                        .size(.fill, .fill)
                        .style(StyleSheet.randomColorStyle)
                }
                .padding(padding.asOutput().map { UIEdgeInsets(top: $0, left: $0, bottom: $0, right: $0) })
                .justifyContent(.center)
                .size(.fill, 100)
                .animator(Animators.default)

            },
            selectors: [0, 10, 20, 30, 40].map { Selector(desc: "\($0)", value: $0) },
            selected: padding.value,
            desc: "Box padding"
        )
        .attach()
        .onEvent(padding)
        .view
    }

    func space() -> UIView {
        let space = State<CGFloat>(0)
        return DemoView<CGFloat>(
            title: "space",
            builder: {
                HBox().attach($0) {
                    Label.demo("1").attach($0)
                    Label.demo("2").attach($0)
                    Label.demo("3").attach($0)
                }
                .padding(all: 10)
                .justifyContent(.center)
                .size(.fill, 60)
                .space(space)
                .animator(Animators.default)

            },
            selectors: [Selector(desc: "0", value: 0),
                        Selector(desc: "10", value: 10),
                        Selector(desc: "20", value: 20),
                        Selector(desc: "30", value: 30),
                        Selector(desc: "40", value: 40)],
            selected: space.value,
            desc: "Control subviews's space"
        )
        .attach()
        .onEvent(space)
        .view
    }

    func reverse() -> UIView {
        let reverse = State<Bool>(false)
        return DemoView<Bool>(
            title: "reverse",
            builder: {
                HBox().attach($0) {
                    Label.demo("1").attach($0)
                    Label.demo("2").attach($0)
                    Label.demo("3").attach($0)
                }
                .padding(all: 10)
                .justifyContent(.center)
                .size(.fill, 60)
                .space(30)
                .reverse(reverse)
                .animator(Animators.default)

            },
            selectors: [Selector(desc: "true", value: true),
                        Selector(desc: "false", value: false)],
            selected: reverse.value,
            desc: "Layout the subviews with reverse to the adding order"
        )
        .attach()
        .onEvent(reverse)
        .view
    }
}
