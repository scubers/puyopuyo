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
        let last = elements.value.last ?? 0
        elements.value.append(last + 1)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.flowView?.layoutIfNeeded()
        }, completion: nil)
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
                Label("""
                Change device to landscape.
                Double click block to remove it
                Single tap when arrange = 0, the view will be the last of the row
                """).attach($0)
                    .textAlignment(.left)
                    .numberOfLines(0)
                    .fontSize(20, weight: .bold)

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
                .set(\.alwaysBounceHorizontal, true)
                .size(.fill, 40)

                getSelectionView(title: "step",
                                 input: step,
                                 values: [Selector<Int>(desc: "0", value: 0),
                                          Selector<Int>(desc: "1", value: 1),
                                          Selector<Int>(desc: "2", value: 2)],
                                 selected: step.value).attach($0)
                getSelectionView(title: "direction",
                                 input: direction,
                                 values: [Selector<Direction>(desc: ".x", value: .x),
                                          Selector<Direction>(desc: ".y", value: .y)],
                                 selected: direction.value).attach($0)
                getSelectionView(title: "width",
                                 input: width,
                                 values: [Selector<SizeDescription>(desc: ".fill", value: .fill),
                                          Selector<SizeDescription>(desc: ".wrap", value: .wrap)],
                                 selected: width.value).attach($0)

                getSelectionView(title: "height",
                                 input: height,
                                 values: [Selector<SizeDescription>(desc: ".fill", value: .fill),
                                          Selector<SizeDescription>(desc: ".wrap", value: .wrap)],
                                 selected: height.value).attach($0)

                getSelectionView(title: "arrange",
                                 input: arrange,
                                 values: (0 ..< 10).map {
                                     Selector<Int>(desc: "\($0)", value: $0)
                                 },
                                 selected: arrange.value).attach($0)

                getSelectionView(title: "padding",
                                 input: padding,
                                 values: [Selector<CGFloat>(desc: "0", value: 0),
                                          Selector<CGFloat>(desc: "10", value: 10),
                                          Selector<CGFloat>(desc: "20", value: 20),
                                          Selector<CGFloat>(desc: "40", value: 30)],
                                 selected: padding.value).attach($0)
                getSelectionView(title: "itemSpace",
                                 input: itemSpace,
                                 values: [Selector<CGFloat>(desc: "0", value: 0),
                                          Selector<CGFloat>(desc: "10", value: 10),
                                          Selector<CGFloat>(desc: "20", value: 20),
                                          Selector<CGFloat>(desc: "30", value: 30),
                                          Selector<CGFloat>(desc: "40", value: 40)],
                                 selected: itemSpace.value).attach($0)

                getSelectionView(title: "runSpace",
                                 input: runSpace,
                                 values: [Selector<CGFloat>(desc: "0", value: 0),
                                          Selector<CGFloat>(desc: "10", value: 10),
                                          Selector<CGFloat>(desc: "20", value: 20),
                                          Selector<CGFloat>(desc: "30", value: 30),
                                          Selector<CGFloat>(desc: "40", value: 40)],
                                 selected: runSpace.value).attach($0)

                getSelectionView(title: "reverse",
                                 input: reverse,
                                 values: [Selector<Bool>(desc: "true", value: true),
                                          Selector<Bool>(desc: "false", value: false)],
                                 selected: reverse.value).attach($0)

                getSelectionView(title: "format",
                                 input: format,
                                 values: Format.allCases.map {
                                     Selector<Format>(desc: "\($0)", value: $0)
                                 },
                                 selected: format.value).attach($0)

                getSelectionView(title: "runFormat",
                                 input: runFormat,
                                 values: Format.allCases.map {
                                     Selector<Format>(desc: "\($0)", value: $0)
                                 },
                                 selected: runFormat.value).attach($0)

                getSelectionView(title: "justifyContent",
                                 input: justifyContent,
                                 values: (Alignment.vertAlignments() + Alignment.horzAlignments()).map {
                                     Selector<Alignment>(desc: "\($0)", value: $0)
                                 },
                                 selected: justifyContent.value).attach($0)
            }
            .padding(all: 4)
        }
    }

    private var flowView: UIView?

    func getFlow() -> FlowBox {
        let this = WeakableObject(value: self)
        return VFlowBuilder<Int>(items: elements.asOutput()) { [weak self] o, i in
            guard let self = self else {
                return UIView()
            }
            let base: CGFloat = 40
            let width = Outputs.combine(o.data, self.step, self.blockFix).map { idx, step, blockFixed -> SizeDescription in
                let size = base + CGFloat(step) * CGFloat(idx)
                return blockFixed ? SizeDescription.fix(size) : .wrap(add: size)
            }

            return Label.demo("").attach()
                .text(o.data.description)
                .backgroundColor(Util.randomColor())
                .width(width)
                .height(width)
                .set(\.py_measure.flowEnding, self.endings.combine(o.data).map { v, idx in
                    v.contains(idx)
                })
                .onTap {
                    print("----")
                }
                .animator(o.data.map { v -> Animator? in
                    switch v % 3 {
                    case 0: return ExpandAnimator() as Animator
                    case 1: return SpinAnimator() as Animator
                    case 2: return nil
                    default: return nil
                    }
                })
                .attach { v in
                    let doubleTap = UITapGestureRecognizer()
                    doubleTap.numberOfTapsRequired = 2
                    doubleTap.py_addAction { _ in
                        i.inContext { c in
                            this.value?.elements.value.remove(at: c.indexPath.row)
                        }
                    }
                    v.addGestureRecognizer(doubleTap)

                    let tap = UITapGestureRecognizer()
                    tap.require(toFail: doubleTap)
                    tap.py_addAction { _ in
                        i.inContext { c in
                            this.value?.toggleEndings(c.indexPath.row)
                        }
                    }
                    v.addGestureRecognizer(tap)
                }
                .view
        }
        .attach()
        .view
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
                .backgroundColor(.lightGray.withAlphaComponent(0.5))
                .autoJudgeScroll(true)
        }
        .view
    }

    override func shouldRandomColor() -> Bool {
        return false
    }
}
