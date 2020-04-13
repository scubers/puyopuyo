//
//  ZPropertiesVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/12/10.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Puyopuyo
import UIKit

class ZPropertiesVC: BaseVC {

    override func configView() {
        HBox().attach(vRoot) {
            self.getMenu().attach($0).size(.fill, .fill)
            self.getZBox().attach($0).size(.fill, .fill)
        }
        .size(.fill, .fill)
    }

    let text = State("demo")

    let width = State<SizeDescription>(.fill)
    let height = State<SizeDescription>(.fill)
    let alignmentVert = State<Alignment>(.center)
    let alignmentHorz = State<Alignment>(.center)

    let alignmentVertRatio = State<CGFloat>(1)
    let alignmentHorzRatio = State<CGFloat>(1)

    let marginTop = State<CGFloat>(0)
    let marginLeft = State<CGFloat>(0)
    let marginBottom = State<CGFloat>(0)
    let marginRight = State<CGFloat>(0)

    let paddingTop = State<CGFloat>(0)
    let paddingLeft = State<CGFloat>(0)
    let paddingBottom = State<CGFloat>(0)
    let paddingRight = State<CGFloat>(0)

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
                Label("请横屏使用\nChange to landscape").attach($0)
                    .textAlignment(.left)
                    .numberOfLines(0)

                HBox().attach($0) {
                    UILabel().attach($0)
                        .text("input:")
                    UITextField().attach($0)
                        .size(.fill, .fill)
                        .onText(self.text)
                }
                .justifyContent(.center)
                .size(.fill, 30)

                getSelectionView(title: "Width",
                                 input: self.width,
                                 values: [Selector<SizeDescription>(desc: ".fill", value: .fill),
                                          Selector<SizeDescription>(desc: ".fix(100)", value: .fix(100)),
                                          Selector<SizeDescription>(desc: ".wrap", value: .wrap)])
                    .attach($0)
                getSelectionView(title: "Height",
                                 input: self.height,
                                 values: [Selector<SizeDescription>(desc: ".fill", value: .fill),
                                          Selector<SizeDescription>(desc: ".fix(100)", value: .fix(100)),
                                          Selector<SizeDescription>(desc: ".wrap", value: .wrap)])
                    .attach($0)

                getSelectionView(title: "H alignment",
                                 input: self.alignmentHorz,
                                 values: Alignment.horzAlignments().map {
                                     Selector(desc: "\($0)", value: $0)
                                 })
                    .attach($0)
                let ratios: [CGFloat] = [0, 0.5, 1, 1.5, 2]
                getSelectionView(title: "H aligment ratio",
                                 input: self.alignmentHorzRatio,
                                 values: ratios.map {
                                     Selector<CGFloat>(desc: "\($0)", value: $0)
                                 })
                    .attach($0)

                getSelectionView(title: "V alignment",
                                 input: self.alignmentVert,
                                 values: Alignment.vertAlignments().map {
                                     Selector(desc: "\($0)", value: $0)
                                 })
                    .attach($0)
                getSelectionView(title: "V aligment ratio",
                                 input: self.alignmentVertRatio,
                                 values: ratios.map {
                                     Selector<CGFloat>(desc: "\($0)", value: $0)
                             })
                    .attach($0)

                let insets: [CGFloat] = [0, 10, 20, 30, 40]
                getSelectionView(title: "MarginTop",
                                 input: self.marginTop,
                                 values: insets.map {
                                     Selector<CGFloat>(desc: "\($0)", value: $0)
                             })
                    .attach($0)
                getSelectionView(title: "MarginLeft",
                                 input: self.marginLeft,
                                 values: insets.map {
                                     Selector<CGFloat>(desc: "\($0)", value: $0)
                             })
                    .attach($0)
                getSelectionView(title: "MarginBottom",
                                 input: self.marginBottom,
                                 values: insets.map {
                                     Selector<CGFloat>(desc: "\($0)", value: $0)
                             })
                    .attach($0)
                getSelectionView(title: "MarginRight",
                                 input: self.marginRight,
                                 values: insets.map {
                                     Selector<CGFloat>(desc: "\($0)", value: $0)
                             })
                    .attach($0)
                getSelectionView(title: "PaddingTop",
                                 input: self.paddingTop,
                                 values: insets.map {
                                     Selector<CGFloat>(desc: "\($0)", value: $0)
                             })
                    .attach($0)
                getSelectionView(title: "PaddingLeft",
                                 input: self.paddingLeft,
                                 values: insets.map {
                                     Selector<CGFloat>(desc: "\($0)", value: $0)
                             })
                    .attach($0)
                getSelectionView(title: "PaddingBottom",
                                 input: self.paddingBottom,
                                 values: insets.map {
                                     Selector<CGFloat>(desc: "\($0)", value: $0)
                         })
                    .attach($0)
                getSelectionView(title: "PaddingRight",
                                 input: self.paddingRight,
                                 values: insets.map {
                                     Selector<CGFloat>(desc: "\($0)", value: $0)
                         })
                    .attach($0)
            }
            .padding(all: 4)
        }
        .attach()
        .setDelegate(self)
        .view
    }

    func getZBox() -> UIView {
        let alignment = SimpleOutput.merge([alignmentVert.asOutput(), alignmentHorz.asOutput()]).map { [weak self] a -> Alignment in
            guard let self = self else { return a }
            return self.alignmentVert.value.union(self.alignmentHorz.value)
        }

        return
            ZBox().attach {
                ZBox().attach($0) {
                    Label.demo("").attach($0)
                        .text(self.text)
                        .alignment(alignment)
                        .alignmentRatio(horz: self.alignmentHorzRatio, vert: self.alignmentVertRatio)
                        .size(self.width, self.height)
                        .margin(top: self.marginTop, left: self.marginLeft, bottom: self.marginBottom, right: self.marginRight)
                }
                .borders([.color(UIColor.lightGray), .thick(Util.pixel(1))])
                .animator(Animators.default)
                .size(.fill, .fill)
                .padding(top: self.paddingTop, left: self.paddingLeft, bottom: self.paddingBottom, right: self.paddingRight)
            }
            .attach { Util.randomViewColor(view: $0) }
            .padding(all: 16)
            .animator(Animators.default)
            .view
    }
}
