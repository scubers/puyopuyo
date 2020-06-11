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
        HBox().attach(vRoot) {
            self.getMenu().attach($0)
                .size(.fill, .fill)
            self.getDemoFlow().attach($0)
                .size(.fill, .fill)
        }
        .size(.fill, .fill)

        self.step.safeBind(to: self) { this, _ in
            this.reset()
        }

//        self.blockFix.safeBind(to: self) { this, _ in
//            this.reset()
//        }
    }

    func reset() {
        self.elementCount.input(value: 10)
    }

    let width = State(SizeDescription.fill)
    let height = State(SizeDescription.fill)
    let arrange = State(4)
    let direction = State(Direction.y)
    let hspace = State<CGFloat>(10)
    let vspace = State<CGFloat>(10)
    let reverse = State<Bool>(false)
    let padding = State<CGFloat>(0)
    let hformat = State<Format>(.leading)
    let vformat = State<Format>(.leading)

    let content = State<Alignment>([.top, .left])

    let elementCount = State(10)

    let adding = SimpleIO<Void>()

    let step = State(2)

    let blockFix = State(true)

    func getMenu() -> UIView {
        func getSelectionView<T: Equatable, I: Inputing>(title: String, input: I, values: [Selector<T>]) -> UIView where I.InputType == T {
            return HBox().attach {
                UILabel().attach($0)
                    .text(title)
                PlainSelectionView<T>(values).attach($0)
                    .size(.fill, 50)
                    .onEventProduced(SimpleInput {
                        input.input(value: $0.value)
                    })
            }
            .space(8)
            .padding(horz: 4)
            .borders([.thick(Util.pixel(1)), .color(Theme.dividerColor)])
            .justifyContent(.center)
            .width(.fill)
            .view
        }
        return ScrollingBox<VBox> {
            $0.attach {
                Label("请横屏使用\nChange to landscape\n double click(remove) or click(when arrange = 0)").attach($0)
                    .textAlignment(.left)
                    .numberOfLines(0)

                ScrollingBox<HBox> {
                    $0.attach {
                        Label.demo("reset").attach($0)
                            .style(TapScaleStyle())
                            .onTap(to: self) { this, _ in
                                this.elementCount.input(value: 10)
                            }
                        Label.demo("add").attach($0)
                            .style(TapScaleStyle())
                            .onTap(to: self) { this, _ in
                                this.adding.input(value: ())
                            }

                        Label.demo("block fix").attach($0)
                            .style(TapScaleStyle())
                            .onTap(to: self) { this, _ in
                                this.blockFix.input(value: true)
                            }

                        Label.demo("block wrap").attach($0)
                            .style(TapScaleStyle())
                            .onTap(to: self) { this, _ in
                                this.blockFix.input(value: false)
                            }
                    }
                    .space(10)
                    .justifyContent(.center)
                }
                .attach($0)
                .scrollDirection(.x)
                .alwaysHorzBounds(true)
                .size(.fill, 40)

                getSelectionView(title: "step",
                                 input: self.step,
                                 values: [Selector<Int>(desc: "0", value: 0),
                                          Selector<Int>(desc: "1", value: 1),
                                          Selector<Int>(desc: "2", value: 2)])
                    .attach($0)
                getSelectionView(title: "direction",
                                 input: self.direction,
                                 values: [Selector<Direction>(desc: ".x", value: .x),
                                          Selector<Direction>(desc: ".y", value: .y)])
                    .attach($0)
                getSelectionView(title: "width",
                                 input: self.width,
                                 values: [Selector<SizeDescription>(desc: ".fill", value: .fill),
                                          Selector<SizeDescription>(desc: ".wrap", value: .wrap)])
                    .attach($0)

                getSelectionView(title: "height",
                                 input: self.height,
                                 values: [Selector<SizeDescription>(desc: ".fill", value: .fill),
                                          Selector<SizeDescription>(desc: ".wrap", value: .wrap)])
                    .attach($0)

                getSelectionView(title: "arrange",
                                 input: self.arrange,
                                 values: (0 ..< 10).map {
                                     Selector<Int>(desc: "\($0)", value: $0)
                                   })
                    .attach($0)

                getSelectionView(title: "padding",
                                 input: self.padding,
                                 values: [Selector<CGFloat>(desc: "0", value: 0),
                                          Selector<CGFloat>(desc: "10", value: 10),
                                          Selector<CGFloat>(desc: "20", value: 20),
                                          Selector<CGFloat>(desc: "40", value: 30)])
                    .attach($0)
                getSelectionView(title: "hSpace",
                                 input: self.hspace,
                                 values: [Selector<CGFloat>(desc: "10", value: 10),
                                          Selector<CGFloat>(desc: "20", value: 20),
                                          Selector<CGFloat>(desc: "30", value: 30),
                                          Selector<CGFloat>(desc: "40", value: 40)])
                    .attach($0)

                getSelectionView(title: "vSpace",
                                 input: self.vspace,
                                 values: [Selector<CGFloat>(desc: "10", value: 10),
                                          Selector<CGFloat>(desc: "20", value: 20),
                                          Selector<CGFloat>(desc: "30", value: 30),
                                          Selector<CGFloat>(desc: "40", value: 40)])
                    .attach($0)

                getSelectionView(title: "reverse",
                                 input: self.reverse,
                                 values: [Selector<Bool>(desc: "true", value: true),
                                          Selector<Bool>(desc: "false", value: false)])
                    .attach($0)

                getSelectionView(title: "hformat",
                                 input: self.hformat,
                                 values: Format.allCases.map {
                                     Selector<Format>(desc: "\($0)", value: $0)
                                   })
                    .attach($0)

                getSelectionView(title: "vformat",
                                 input: self.vformat,
                                 values: Format.allCases.map {
                                     Selector<Format>(desc: "\($0)", value: $0)
                                   })
                    .attach($0)

                getSelectionView(title: "content",
                                 input: self.content,
                                 values: (Alignment.vertAlignments() + Alignment.horzAlignments()).map {
                                     Selector<Alignment>(desc: "\($0)", value: $0)
                                   })
                    .attach($0)
            }
            .padding(all: 4)
        }
    }

    func getFlow() -> FlowBox {
        return
            VFlow().attach {
                let v = $0

                _ = self.elementCount.outputing { [weak self] _ in
                    v.subviews.forEach { $0.removeFromSuperview() }

                    for idx in 0 ..< 10 {
                        self?.getLabel(idx: idx).attach(v)
                    }
                }

                _ = self.adding.outputing { [weak self] in
                    let count = v.subviews.count
                    self?.getLabel(idx: count).attach(v)
                }
            }
            .space(2)
            .padding(all: 4)
            .view
    }

    func getLabel(idx: Int) -> UIView {
        let base: CGFloat = 40
        let width = base + CGFloat(self.step.value * idx)
        let v = Label.demo("\(idx + 1)").attach()
            .backgroundColor(Util.randomColor())
            .width(self.blockFix.value ? SizeDescription.fix(width) : .wrap(add: width))
            .height(self.blockFix.value ? SizeDescription.fix(width) : .wrap(add: width))
            .attach { v in
                let doubleTap = UITapGestureRecognizer()
                doubleTap.numberOfTapsRequired = 2
                doubleTap.py_addAction {
                    $0.view?.removeFromSuperview()
                }
                v.addGestureRecognizer(doubleTap)

                let tap = UITapGestureRecognizer()
                tap.require(toFail: doubleTap)
                tap.py_addAction { g in
                    guard let v = g.view else { return }
                    v.attach().flowEnding(!v.py_measure.flowEnding)
                }
                v.addGestureRecognizer(tap)
            }
            .view

        return v
    }

    func getDemoFlow() -> UIView {
        return UIScrollView().attach {
            self.getFlow().attach($0)
                .arrangeCount(self.arrange)
                .animator(Animators.default)
                .direction(self.direction)
                .width(self.width)
                .height(self.height)
                .hSpace(self.hspace)
                .vSpace(self.vspace)
                .reverse(self.reverse)
                .hFormat(self.hformat)
                .vFormat(self.vformat)
                .justifyContent(self.content)
                .padding(self.padding.asOutput().map { UIEdgeInsets(top: $0, left: $0, bottom: $0, right: $0) })
                .backgroundColor(UIColor.lightGray.withAlphaComponent(0.5))
                .autoJudgeScroll(true)
        }
        .view
    }

    override func shouldRandomColor() -> Bool {
        return false
    }
}
