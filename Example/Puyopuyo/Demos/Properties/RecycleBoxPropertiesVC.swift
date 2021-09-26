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
                        this.reloadMultipleSectionToOne()
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

    func colorBlocks() {
        let color = Util.randomColor()
        sections.value = [
            DataRecycleSection(
                lineSpacing: 10,
                itemSpacing: 10,
                items: (0..<6).map { $0 }.asOutput(),
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

    func reloadMultipleSectionToOne() {
        let dataSource = State([
            (0..<5).map { $0 },
            (5..<10).map { $0 },
            (6..<20).map { $0 }
        ])

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            dataSource.value = [(0..<20).reversed().map { $0 }]
        }

        dataSource.map { sections -> [IRecycleSection] in
            sections.map { rows in
                BasicRecycleSection(
                    data: (),
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
                    return VBox().attach {
                        UILabel().attach($0)
                            .text(o.data.map { $0 + 1 }.binder.description)
                            .width(.fill)
                            .textAlignment(.center)

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
                    .size(w, w)
                    .backgroundColor(Outputs.combine(o.data, selected).map { $0 == $1 }.map { $0 ? UIColor.systemPink : .clear
                    })
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
