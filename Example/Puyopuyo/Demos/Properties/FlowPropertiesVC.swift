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
            getMenu().attach($0)
                .size(.fill, .fill)
            getDemoFlow().attach($0)
                .size(.fill, .fill)
        }
        .size(.fill, .fill)

        step.safeBind(to: self) { this, _ in
            this.reset()
        }
    }

    func reset() {
        elements.input(value: (0 ..< 10).map { $0 })
        endings.value = []
    }

    let width = State(SizeDescription.fill)
    let height = State(SizeDescription.fill)
    let arrange = State(4)
    let direction = State(Direction.y)
    let itemSpace = State<CGFloat>(10)
    let runSpace = State<CGFloat>(10)
    let reverse = State<Bool>(false)
    let padding = State<CGFloat>(0)
    let format = State<Format>(.leading)
    let runFormat = State<Format>(.leading)

    let justifyContent = State<Alignment>([.top])

    let elements = State((0 ..< 10).map { $0 })
    let endings = State<[Int]>([])

    func increase() {
        elements.value.append(elements.value.count)
    }

    func toggleEndings(_ value: Int) {
        if endings.value.contains(value) {
            endings.value.removeAll(where: { $0 == value })
        } else {
            endings.value.append(value)
        }
    }

    let step = State(2)

    let blockFix = State(true)

    func getMenu() -> UIView {
        func getSelectionView<T: Equatable, I: Inputing>(title: String, input: I, values: [Selector<T>], selected: T? = nil) -> UIView where I.InputType == T {
            return HBox().attach {
                UILabel().attach($0)
                    .text(title)
                PlainSelectionView<T>(values, selected: selected).attach($0)
                    .size(.fill, 50)
                    .onEvent(input)
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
                            .style(TapTransformStyle())
                            .onTap(to: self) { this, _ in
                                this.reset()
                            }
                        Label.demo("add").attach($0)
                            .style(TapTransformStyle())
                            .onTap(to: self) { this, _ in
                                this.increase()
                            }

                        Label.demo("block fix").attach($0)
                            .style(TapTransformStyle())
                            .onTap(to: self) { this, _ in
                                this.blockFix.input(value: true)
                            }

                        Label.demo("block wrap").attach($0)
                            .style(TapTransformStyle())
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
                                 input: step,
                                 values: [Selector<Int>(desc: "0", value: 0),
                                          Selector<Int>(desc: "1", value: 1),
                                          Selector<Int>(desc: "2", value: 2)],
                                 selected: step.value)
                    .attach($0)
                getSelectionView(title: "direction",
                                 input: direction,
                                 values: [Selector<Direction>(desc: ".x", value: .x),
                                          Selector<Direction>(desc: ".y", value: .y)],
                                 selected: direction.value)
                    .attach($0)
                getSelectionView(title: "width",
                                 input: width,
                                 values: [Selector<SizeDescription>(desc: ".fill", value: .fill),
                                          Selector<SizeDescription>(desc: ".wrap", value: .wrap)],
                                 selected: width.value)
                    .attach($0)

                getSelectionView(title: "height",
                                 input: height,
                                 values: [Selector<SizeDescription>(desc: ".fill", value: .fill),
                                          Selector<SizeDescription>(desc: ".wrap", value: .wrap)],
                                 selected: height.value)
                    .attach($0)

                getSelectionView(title: "arrange",
                                 input: arrange,
                                 values: (0 ..< 10).map {
                                     Selector<Int>(desc: "\($0)", value: $0)
                                 },
                                 selected: arrange.value)
                    .attach($0)

                getSelectionView(title: "padding",
                                 input: padding,
                                 values: [Selector<CGFloat>(desc: "0", value: 0),
                                          Selector<CGFloat>(desc: "10", value: 10),
                                          Selector<CGFloat>(desc: "20", value: 20),
                                          Selector<CGFloat>(desc: "40", value: 30)],
                                 selected: padding.value)
                    .attach($0)
                getSelectionView(title: "itemSpace",
                                 input: itemSpace,
                                 values: [Selector<CGFloat>(desc: "0", value: 0),
                                          Selector<CGFloat>(desc: "10", value: 10),
                                          Selector<CGFloat>(desc: "20", value: 20),
                                          Selector<CGFloat>(desc: "30", value: 30),
                                          Selector<CGFloat>(desc: "40", value: 40)],
                                 selected: itemSpace.value)
                    .attach($0)

                getSelectionView(title: "runSpace",
                                 input: runSpace,
                                 values: [Selector<CGFloat>(desc: "0", value: 0),
                                          Selector<CGFloat>(desc: "10", value: 10),
                                          Selector<CGFloat>(desc: "20", value: 20),
                                          Selector<CGFloat>(desc: "30", value: 30),
                                          Selector<CGFloat>(desc: "40", value: 40)],
                                 selected: runSpace.value)
                    .attach($0)

                getSelectionView(title: "reverse",
                                 input: reverse,
                                 values: [Selector<Bool>(desc: "true", value: true),
                                          Selector<Bool>(desc: "false", value: false)],
                                 selected: reverse.value)
                    .attach($0)

                getSelectionView(title: "format",
                                 input: format,
                                 values: Format.allCases.map {
                                     Selector<Format>(desc: "\($0)", value: $0)
                                 },
                                 selected: format.value)
                    .attach($0)

                getSelectionView(title: "runFormat",
                                 input: runFormat,
                                 values: Format.allCases.map {
                                     Selector<Format>(desc: "\($0)", value: $0)
                                 },
                                 selected: runFormat.value)
                    .attach($0)

                getSelectionView(title: "justifyContent",
                                 input: justifyContent,
                                 values: (Alignment.vertAlignments() + Alignment.horzAlignments()).map {
                                     Selector<Alignment>(desc: "\($0)", value: $0)
                                 },
                                 selected: justifyContent.value)
                    .attach($0)
            }
            .padding(all: 4)
        }
    }

    func getFlow() -> FlowBox {
        let this = WeakCatcher(value: self)
        return VFlowRecycle<Int> { [weak self] o, i in
            guard let self = self else {
                return UIView()
            }
            let base: CGFloat = 40
            let width = Outputs.combine(o, self.step, self.blockFix).map { idx, step, blockFixed -> SizeDescription in
                let size = base + CGFloat(step) * CGFloat(idx)
                return blockFixed ? SizeDescription.fix(size) : .wrap(add: size)
            }

            return Label.demo("").attach()
                .text(o.map(\.description))
                .backgroundColor(Util.randomColor())
                .width(width)
                .height(width)
                .bind(keyPath: \.py_measure.flowEnding, self.endings.combine(o).map { v, idx in
                    v.contains(idx)
                })
                .onTap {
                    print("----")
                }
                .attach { v in
                    let doubleTap = UITapGestureRecognizer()
                    doubleTap.numberOfTapsRequired = 2
                    doubleTap.py_addAction { _ in
                        i.inContext { c in
                            this.value?.elements.value.remove(at: c.index)
                        }
                    }
                    v.addGestureRecognizer(doubleTap)

                    let tap = UITapGestureRecognizer()
                    tap.require(toFail: doubleTap)
                    tap.py_addAction { _ in
                        i.inContext { c in
                            this.value?.toggleEndings(c.index)
                        }
                    }
                    v.addGestureRecognizer(tap)
                }
                .view
        }
        .attach()
        .viewState(elements)
        .view
    }

    func getLabel(idx: Int) -> UIView {
        let base: CGFloat = 40
        let width = base + CGFloat(step.value * idx)
        let v = Label.demo("\(idx + 1)").attach()
            .backgroundColor(Util.randomColor())
            .width(blockFix.value ? SizeDescription.fix(width) : .wrap(add: width))
            .height(blockFix.value ? SizeDescription.fix(width) : .wrap(add: width))
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
        UIScrollView().attach {
            getFlow().attach($0)
                .arrangeCount(arrange)
                .animator(Animators.default)
                .direction(direction)
                .width(width)
                .height(height)
                .itemSpace(itemSpace)
                .runSpace(runSpace)
                .reverse(reverse)
                .format(format)
                .runFormat(runFormat)
                .justifyContent(justifyContent)
                .padding(all: padding)
                .backgroundColor(UIColor.lightGray.withAlphaComponent(0.5))
                .autoJudgeScroll(true)
        }
        .view
    }

    override func shouldRandomColor() -> Bool {
        return false
    }
}
