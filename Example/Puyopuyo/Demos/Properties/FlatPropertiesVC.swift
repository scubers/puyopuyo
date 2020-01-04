//
//  FlatPropertiesVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/12/8.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Puyopuyo
import UIKit

class FlatPropertiesVC: BaseVC {
    override func configView() {
        DemoScroll(
            builder: {
                self.direction().attach($0)
                self.format().attach($0)
                self.justifyContent().attach($0)
                self.activate().attach($0)
                self.space().attach($0)
                self.reverse().attach($0)
                self.padding().attach($0)
            }
        )
        .attach(vRoot)
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
                .size(.fill, 60)
                .animator(Animators.default)
                .view
            },
            selectors: [Selector(desc: "top", value: .top),
                        Selector(desc: "bottom", value: .bottom),
                        Selector(desc: "center", value: .center)],
            desc: """
            Box.justfyContent，布局次轴上用于统一控制子View的偏移
            """
        )
        .attach()
        .onEventProduced(to: self, { _, x in
            justifyContent.value = x
        })
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
                .size(.fill, 60)
                .animator(Animators.default)
                .view
            },
            selectors: [Selector(desc: "top", value: .top),
                        Selector(desc: "bottom", value: .bottom),
                        Selector(desc: "center", value: .center)],
            desc: """
            activate = false, 则不受布局控制，可自由设置frame
            """
        )
        .attach()
        .onEventProduced(to: self, { _, x in
            justifyContent.value = x
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
                        Selector(desc: "center", value: .center),
                        Selector(desc: "avg", value: .round),
                        Selector(desc: "sides", value: .between),
                        Selector(desc: "traing", value: .trailing)],
            desc: "布局主轴上的格式"
        )
        .attach()
        .onEventProduced(to: self, { _, x in
            format.value = x
        })
        .view
    }

    func direction() -> UIView {
        let direction = State<Direction>(.x)
        return DemoView<Direction>(
            title: "direction",
            builder: {
                FlatBox().attach($0) {
                    Label.demo("1").attach($0)
                    Label.demo("2").attach($0)
                    Label.demo("3").attach($0)
                }
                .space(2)
                .padding(all: 10)
                .justifyContent(.center)
                .size(.fill, 80)
                .animator(Animators.default)
                .direction(direction)
                .view
            },
            selectors: [Selector(desc: "x", value: .x),
                        Selector(desc: "y", value: .y)],
            desc: """
            x: 水平方向
            y: 竖直方向
            """
        )
        .attach()
        .onEventProduced(to: self, { _, x in
            direction.value = x
        })
        .view
    }

    func padding() -> UIView {
        let padding = State<CGFloat>(0)
        return DemoView<CGFloat>(
            title: "padding",
            builder: {
                HBox().attach($0) {
                    //                    Label.demo("1").attach($0)
                    //                    Label.demo("2").attach($0)
                    //                    Label.demo("3").attach($0)
                    UIView().attach($0)
                        .size(.fill, .fill)
                        .style(StyleSheet.randomColorStyle)
                }
                .padding(padding.asOutput().map({ UIEdgeInsets(top: $0, left: $0, bottom: $0, right: $0) }))
                .justifyContent(.center)
                .size(.fill, 100)
                .animator(Animators.default)
                .view
            },
            selectors: [0, 10, 20, 30, 40].map({ Selector(desc: "\($0)", value: $0) }),
            desc: "Box布局系统的内边距"
        )
        .attach()
        .onEventProduced(to: self, { _, x in
            padding.value = x
        })
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
                .view
            },
            selectors: [Selector(desc: "0", value: 0),
                        Selector(desc: "10", value: 10),
                        Selector(desc: "20", value: 20),
                        Selector(desc: "30", value: 30),
                        Selector(desc: "40", value: 40)],
            desc: "布局系统子view间距"
        )
        .attach()
        .onEventProduced(to: self, { _, x in
            space.value = x
        })
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
                .view
            },
            selectors: [Selector(desc: "true", value: true),
                        Selector(desc: "false", value: false)],
            desc: "布局系统是否逆向布局"
        )
        .attach()
        .onEventProduced(to: self, { _, x in
            reverse.value = x
        })
        .view
    }

    override func shouldRandomColor() -> Bool {
        return false
    }
}
