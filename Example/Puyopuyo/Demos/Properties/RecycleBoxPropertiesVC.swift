//
//  RecycleBoxPropertiesVC.swift
//  Puyopuyo_Example
//
//  Created by 王俊仁 on 2020/5/12.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import Puyopuyo

class RecycleBoxPropertiesVC: BaseVC {
    let sections = State<[IRecycleSection]>([])
    var box: RecycleBox?

    override func configView() {
        vRoot.attach {
            HBox().attach($0) {
                Label.demo("demo1").attach($0)
                    .onTap(to: self) { this, _ in
                        this.reloadWithMultipleSectionAnimationSeparated()
                    }

                Label.demo("demo2").attach($0)
                    .onTap(to: self) { this, _ in
                        this.sectionDiff()
                    }
                Label.demo("demo3").attach($0)
                    .onTap(to: self) { this, _ in
                        this.randomShuffleAnimation()
                    }

                Label.demo("demo4").attach($0)
                    .onTap(to: self) { this, _ in
                        this.colorBlocks()
                    }
                Label.demo("calendar").attach($0)
                    .onTap(to: self) { this, _ in
                        this.calendar()
                    }
                Label.demo("mix").attach($0)
                    .onTap(to: self) { this, _ in
                        this.mixedDataDemo()
                    }
            }
            .space(10)
            .width(.fill)

            box = RecycleBox(
                headerPinToBounds: true,
                sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10),
                diffable: true,
                sections: sections.asOutput()
            )
            .attach($0)
            .size(.fill, .fill)
            .view
        }
        .space(10)

//        reloadWithMultipleSectionAnimationSeparated()
//        reloadMultipleSectionToOne()
//        randomShuffleAnimation()
//        colorBlocks()
    }

    let mixedDataState = State<[IRecycleItem]>([])
    func mixedDataDemo() {
        func titleItem() -> IRecycleItem {
            BasicRecycleItem(
                data: Names().get(),
                diffableKey: { $0 },
                cell: { o, _ in
                    HBox().attach {
                        UILabel().attach($0)
                            .text(o.data)
                    }
                    .width(.fill)
                    .padding(all: 10)
                    .view
                }
            )
        }

        func colorItem() -> IRecycleItem {
            BasicRecycleItem(
                data: Util.randomColor(),
                diffableKey: { $0.description },
                cell: { o, _ in
                    let w = o.layoutableSize.width.map { floor($0 / 3) }
                    return HBox().attach()
                        .size(w, w.map { $0 / 2 })
                        .backgroundColor(o.data)
                        .view
                }
            )
        }

        let items = [
            titleItem(),

            colorItem(),
            colorItem(),
            colorItem(),

            titleItem(),

            colorItem(),
            colorItem(),
            colorItem(),

            titleItem(),

            colorItem(),
            colorItem(),
            colorItem()
        ]

        mixedDataState.value = items

        let this = WeakCatcher(value: self)

        sections.value = [
            BasicRecycleSection(data: (), items: [
                BasicRecycleItem(data: 1, cell: { _, _ in
                    HBox().attach {
                        Label.demo("All").attach($0)
                            .onTap {
                                this.value?.mixedDataState.value = items
                            }

                        Label.demo("Text").attach($0)
                            .onTap {
                                this.value?.mixedDataState.value = items.filter { $0 is BasicRecycleItem<String> }
                            }

                        Label.demo("Color").attach($0)
                            .onTap {
                                this.value?.mixedDataState.value = items.filter { $0 is BasicRecycleItem<UIColor> }
                            }
                    }
                    .space(10)
                    .width(.fill)
                    .view
                })
            ].asOutput()),
            BasicRecycleSection(
                data: (),
                items: mixedDataState.asOutput()
            )
        ]
    }

    func colorBlocks() {
        let color = Util.randomColor()
        sections.value = [
            DataRecycleSection(
                lineSpacing: 10,
                itemSpacing: 10,
                items: (0..<20).map { $0 }.asOutput(),
                cell: { o, _ in
                    let w = o.layoutableSize.width.map {
                        ($0 - 3 * 10) / 3
                    }
                    return HBox().attach {
                        Label.demo("").attach($0)
                            .text(o.data.description)
                            .size(w, w)
                            .backgroundColor(color)
                    }
                    .view
                }
            )
        ]
    }

    let names = State(Names().random(10))

    func randomShuffleAnimation() {
        let this = WeakCatcher(value: self)
        sections.value = [
            DataRecycleSection(
                items: names.asOutput(),
                differ: { $0 },
                cell: { o, _ in
                    HorzFillCell().attach()
                        .viewState(o.data)
                        .view
                },
                header: { _, _ in
                    HBox().attach {
                        UIButton().attach($0)
                            .image(UIImage(systemName: "play.fill"))
                            .bind(event: .touchUpInside, input: Inputs { _ in
                                this.value?.names.value.shuffle()
                            })
                    }
                    .padding(all: 10)
                    .view
                }
            )
        ]
    }

    func sectionDiff() {
        let dataSource = State([
            (0..<5).map { $0 },
            (5..<10).map { $0 },
            (6..<20).map { $0 }
        ])

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            dataSource.value.remove(at: 0) // remove first
            dataSource.value[1] = (3..<10).map { $0 } // change second
        }

        dataSource.map { sections -> [IRecycleSection] in
            sections.enumerated().map { _, rows in
                BasicRecycleSection(
                    data: (),
                    diffableKey: { "1" }, // Make sure just use item for diffing
                    items: rows.map { row in
                        BasicRecycleItem(
                            data: row,
                            diffableKey: { $0.description },
                            cell: { o, _ in
                                SquareCell().attach()
                                    .viewState(o.data.description)
                                    .view
                            }
                        )

                    }.asOutput(),
                    header: { o, _ in
                        Header().attach()
//                            .viewState(o.indexPath.section.map { "Section \($0)" })
                            .viewState(o.map { "section \($0.indexPath.section)" })
                            .view
                    }
                )
            }
        }
        .send(to: sections)
        .dispose(by: self)
    }

    func reloadWithMultipleSectionAnimationSeparated() {
        let section1 = State((0..<5).map { $0 })
        let section2 = State((6..<10).map { $0 })

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            section1.value = (4..<10).map { $0 }
            section2.value = (4..<20).map { $0 }
        }

        sections.value = [
            DataRecycleSection(
                items: section1.asOutput(),
                differ: { $0.description },
                cell: { o, _ in
                    SquareCell().attach()
                        .viewState(o.data.description)
                        .view
                },
                header: { _, _ in
                    Header().attach()
                        .viewState("Header 1")
                        .view
                }
            ),
            DataRecycleSection(
                items: section2.asOutput(),
                differ: { $0.description },
                cell: { o, _ in
                    SquareCell().attach()
                        .viewState(o.data.description)
                        .view
                },
                header: { _, _ in
                    Header().attach()
                        .viewState("Header 2")
                        .view
                }
            )
        ]
    }

    let selected = State(0)

    let appointments = (0..<30).map { _ in
        Names().random(5)
    }

    let appointment = State<[String]>([])
    func calendar() {
        let selected = selected
        let appointments = appointments
        let appointment = appointment
        sections.value = [
            DataRecycleSection(
                items: (0..<30).map { $0 }.asOutput(),
                cell: { o, _ in
                    let w = o.layoutableSize.width.map { $0 / 7 }
                    let selected = Outputs.combine(o.data, selected).map { $0 == $1 }
                    return ZBox().attach {
                        UIView().attach($0).attach($0)
                            .size(.fill, .fill)
                            .clipToBounds(true)
                            .backgroundColor(selected.map { $0 ? UIColor.systemPink : .clear })
                            .margin(all: 5)
                            .attach {
                                $0.py_sizeState().binder.width.distinct().safeBind(to: $0) { v, s in
                                    v.layer.cornerRadius = s / 2
                                }
                            }
                        VBox().attach($0) {
                            UILabel().attach($0)
                                .width(.fill)
                                .text(o.data.map { $0 + 1 }.binder.description)
                                .textAlignment(.center)
                                .textColor(selected.map { $0 ? UIColor.white : .black })

                            HBoxRecycle<String> { _, _ in
                                UIView().attach()
                                    .backgroundColor(.systemBlue)
                                    .size(4, 4)
                                    .cornerRadius(2)
                                    .view
                            }
                            .attach($0)
                            .viewState(o.data.map { appointments[$0] })
                            .space(4)
                        }
                        .justifyContent(.center)
                        .format(.round)
                        .size(.fill, .fill)
                    }
                    .size(w, w)
                    .view
                },
                didSelect: { o in
                    UIView.animate(withDuration: 0.2) {
                        selected.value = o.data
                        appointment.value = appointments[o.data]
                    }
                }
            ),
            DataRecycleSection(
                items: appointment.asOutput(),
                differ: { $0.description },
                cell: { o, _ in
                    HBox().attach {
                        UILabel().attach($0)
                            .text(o.data)
                            .fontSize(20, weight: .bold)
                    }
                    .padding(all: 10)
                    .width(.fill)
                    .view
                }
            )
        ]
    }
}

private class SquareCell: HBox, Stateful {
    var viewState = State<String>.unstable()

    override func buildBody() {
        attach {
            Label.demo("").attach($0)
                .text(binder.description)
                .size(.wrap(min: 50), .wrap(min: 50))
        }
        .padding(all: 10)
    }
}

private class HorzFillCell: HBox, Stateful {
    var viewState = State<String>.unstable()

    override func buildBody() {
        attach {
            Label.demo("").attach($0)
                .size(.fill, .wrap(min: 50))
                .text(binder)
        }
        .width(.fill)
        .padding(all: 10)
    }
}

private class Header: HBox, Stateful {
    var viewState = State<String>.unstable()
    override func buildBody() {
        attach {
            Label.demo("").attach($0)
                .text(binder)
                .size(.wrap(add: 10), .wrap(add: 10))
        }
    }
}
