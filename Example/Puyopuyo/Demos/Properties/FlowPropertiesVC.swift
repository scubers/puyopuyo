//
//  FlowPropertiesVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/12/8.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Puyopuyo
import UIKit

class FlowPropertiesVC: BaseVC {
    override func configView() {
        DemoScroll(
            builder: {
                self.mixed().attach($0)
            }
        )
        .attach(vRoot)
        .size(.fill, .fill)
    }

    func getFlow() -> FlowBox {
        return
            VFlow().attach {
                for idx in 0 ..< 10 {
                    Label.demo("\(idx + 1)").attach($0)
                        .size(40, 40)
                }
            }
            .space(2)
            .padding(all: 4)
            .view
    }

    func mixed() -> UIView {
        func getSelectionView<T: Equatable, I: Inputing>(title: String, input: I, values: [Selector<T>]) -> UIView where I.InputType == T {
            return HBox().attach {
                UILabel().attach($0)
                    .text(title)
                PlainSelectionView<T>(values).attach($0)
                    .size(.fill, 40)
                    .onEventProduced(SimpleInput {
                        input.input(value: $0.value)
                    })
            }
            .space(2)
            .borders([.thick(0.5), .color(Theme.dividerColor)])
            .justifyContent(.center)
            .width(.fill)
            .view
        }

        let width = State(SizeDescription.fill)
        let height = State(SizeDescription.fill)
        let arrange = State(4)
        let direction = State(Direction.y)
        let hspace = State<CGFloat>(10)
        let vspace = State<CGFloat>(10)
        let reverse = State<Bool>(false)

        let hformat = State<Format>(.leading)
        let vformat = State<Format>(.leading)

        let content = State<Alignment>([.top, .left])

        return DemoView<Bool>(
            title: "reverse",
            builder: {
                VBox().attach($0) {
                    getSelectionView(title: "direction",
                                     input: direction,
                                     values: [Selector<Direction>(desc: ".x", value: .x),
                                              Selector<Direction>(desc: ".y", value: .y)])
                        .attach($0)
                    getSelectionView(title: "width",
                                     input: width,
                                     values: [Selector<SizeDescription>(desc: ".fill", value: .fill),
                                              Selector<SizeDescription>(desc: ".wrap", value: .wrap)])
                        .attach($0)

                    getSelectionView(title: "height",
                                     input: height,
                                     values: [Selector<SizeDescription>(desc: ".fill", value: .fill),
                                              Selector<SizeDescription>(desc: ".wrap", value: .wrap)])
                        .attach($0)

                    getSelectionView(title: "arrange",
                                     input: arrange,
                                     values: (0 ..< 10).map({
                                         Selector<Int>(desc: "\($0)", value: $0)
                    }))
                        .attach($0)

                    getSelectionView(title: "hSpace",
                                     input: hspace,
                                     values: [Selector<CGFloat>(desc: "10", value: 10),
                                              Selector<CGFloat>(desc: "20", value: 20),
                                              Selector<CGFloat>(desc: "30", value: 30),
                                              Selector<CGFloat>(desc: "40", value: 40)])
                        .attach($0)

                    getSelectionView(title: "vSpace",
                                     input: vspace,
                                     values: [Selector<CGFloat>(desc: "10", value: 10),
                                              Selector<CGFloat>(desc: "20", value: 20),
                                              Selector<CGFloat>(desc: "30", value: 30),
                                              Selector<CGFloat>(desc: "40", value: 40)])
                        .attach($0)

                    getSelectionView(title: "reverse",
                                     input: reverse,
                                     values: [Selector<Bool>(desc: "true", value: true),
                                              Selector<Bool>(desc: "false", value: false)])
                        .attach($0)

                    getSelectionView(title: "hformat",
                                     input: hformat,
                                     values: Format.allCases.map({
                                         Selector<Format>(desc: "\($0)", value: $0)
                    }))
                        .attach($0)

                    getSelectionView(title: "vformat",
                                     input: vformat,
                                     values: Format.allCases.map({
                                         Selector<Format>(desc: "\($0)", value: $0)
                    }))
                        .attach($0)

                    getSelectionView(title: "content",
                                     input: content,
                                     values: (Alignment.vertAlignments() + Alignment.horzAlignments()).map({
                                         Selector<Alignment>(desc: "\($0)", value: $0)
                    }))
                        .attach($0)

                    self.getFlow().attach($0)
                        .arrangeCount(arrange)
                        .animator(Animators.default)
                        .direction(direction)
                        .width(width)
                        .height(height)
                        .hSpace(hspace)
                        .vSpace(vspace)
                        .reverse(reverse)
                        .hFormat(hformat)
                        .vFormat(vformat)
                        .justifyContent(content)
                        .backgroundColor(UIColor.lightGray.withAlphaComponent(0.5))
//                        .size(.fill, .wrap)
                }
                .animator(Animators.default)
                .width(.fill)
                .height(height.asOutput().map({ (s) -> SizeDescription in
                    if s.isWrap {
                        return SizeDescription.wrap
                    }
                    return .fix(1000)
                }))
//                .size(.fill, 500)
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
