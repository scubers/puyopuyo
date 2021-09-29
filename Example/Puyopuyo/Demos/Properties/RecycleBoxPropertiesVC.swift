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

    struct MenuItem {
        var name: String
        var action: () -> Void
    }

    override func configView() {
        let this = WeakCatcher(value: self)

        let actions = [
            MenuItem(name: "demo1", action: { this.value?.reloadWithMultipleSectionAnimationSeparated() }),
            MenuItem(name: "demo2", action: { this.value?.sectionDiff() }),
            MenuItem(name: "demo3", action: { this.value?.randomShuffleAnimation() }),
            MenuItem(name: "demo4", action: { this.value?.colorBlocks() }),
            MenuItem(name: "calendar", action: { this.value?.calendar() }),
            MenuItem(name: "mix", action: { this.value?.mixedDataDemo() })
        ]

        vRoot.attach {
            UISegmentedControl(items: actions.map(\.name)).attach($0)
                .bind(keyPath: \.selectedSegmentIndex, 0)
                .bind(event: .valueChanged, input: Inputs {
                    actions[$0.selectedSegmentIndex].action()
                })
                .size(.fill, 40)

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

        actions.first?.action()
    }

    let mixedDataState = State<[IRecycleItem]>([])
    func mixedDataDemo() {
        class TitleItem: BasicRecycleItem<String> {
            init() {
                super.init(
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
        }

        class ColorItem: BasicRecycleItem<UIColor> {
            init() {
                super.init(
                    data: Util.randomColor(),
                    diffableKey: { $0.description },
                    cell: { o, _ in
                        let w = o.contentSize.width.map { floor(($0 / 3) * 100) / 100 }
                        return HBox().attach()
                            .size(w, w.map { $0 / 2 })
                            .backgroundColor(o.data)
                            .diagnosis()
                            .view
                    }
                )
            }
        }

        let items: [IRecycleItem] = [
            TitleItem(),

            ColorItem(),
            ColorItem(),
            ColorItem(),

            TitleItem(),

            ColorItem(),
            ColorItem(),
            ColorItem(),

            TitleItem(),

            ColorItem(),
            ColorItem(),
            ColorItem()
        ]

        mixedDataState.value = items

        let this = WeakCatcher(value: self)

        let actions = [
            MenuItem(name: "All", action: { this.value?.mixedDataState.value = items }),
            MenuItem(name: "Color", action: {
                this.value?.mixedDataState.value = items.filter { $0 is ColorItem }
            }),
            MenuItem(name: "Text", action: {
                this.value?.mixedDataState.value = items.filter { $0 is TitleItem }
            })
        ]

        sections.value = [
            BasicRecycleSection(data: (), items: [
                BasicRecycleItem(data: 1, cell: { _, _ in
                    HBox().attach {
                        UISegmentedControl(items: actions.map(\.name)).attach($0)
                            .size(.fill, 40)
                            .bind(keyPath: \.selectedSegmentIndex, 0)
                            .bind(event: .valueChanged, input: Inputs {
                                actions[$0.selectedSegmentIndex].action()
                            })
                    }
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
                    let w = o.contentSize.width.map {
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
                    header: { _, _ in
                        Header().attach()
                            .viewState("Header")
                            .view
                    }
                )
            }
        }
        .map {
            [getDescSection(title: """
            Section can be calculate diff, the diffable key of the section and item should be provide at the same time.
            Item animation will lost when section animation is occured.
            """)] + $0
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
            getDescSection(title: """
            Change specific section's dataSource, auto calculate diff and animate.
            """),
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
                    let w = o.contentSize.width.map { $0 / 7 }
                    let selected = Outputs.combine(o.data, selected).map { $0 == $1 }
                    let width: CGFloat = 30
                    return VBox().attach {
                        UILabel().attach($0)
                            .size(width, width)
                            .text(o.data.map { $0 + 1 }.binder.description)
                            .textAlignment(.center)
                            .textColor(selected.map { $0 ? UIColor.white : .black })
                            .cornerRadius(width / 2)
                            .backgroundColor(selected.map { $0 ? UIColor.systemPink : .clear })
                            .clipToBounds(true)
                            .animator(selected.map { $0 ? (FatAnimator() as Animator) : nil })

                        HBoxBuilder<String>(items: o.data.map { appointments[$0] }) { _, _ in
                            UIView().attach()
                                .backgroundColor(.systemBlue)
                                .size(4, 4)
                                .cornerRadius(2)
                                .view
                        }
                        .attach($0)
                        .space(4)
                    }
//                    .animator(selected.map { $0 ? (FatAnimator() as Animator) : nil })
                    .justifyContent(.center)
                    .format(.round)
                    .size(w, w)
//                    .attach {
//                        selected.safeBind(to: $0) { if $1 { $0.setNeedsLayout() }}
//                    }
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

private func getDescSection(title: String) -> IRecycleSection {
    BasicRecycleSection(
        data: (),
        items: [
            BasicRecycleItem(
                data: title,
                cell: { o, _ in
                    HBox().attach {
                        UILabel().attach($0)
                            .text(o.data)
                            .fontSize(20, weight: .bold)
                            .numberOfLines(0)
                    }
                    .width(.fill)
                    .view
                }
            )
        ].asOutput()
    )
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

private struct FatAnimator: Animator {
    var duration: TimeInterval { 0.3 }
    func animate(_ delegate: MeasureDelegate, size: CGSize, center: CGPoint, animations: @escaping () -> Void) {
        let view = delegate as? UIView
        runAsNoneAnimation {
            delegate.py_center = center
            delegate.py_size = size
            view?.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1)
        }

        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 2, options: [.curveEaseInOut, .overrideInheritedOptions, .overrideInheritedDuration, .overrideInheritedCurve], animations: {
            view?.layer.transform = CATransform3DIdentity
            animations()
        }, completion: nil)
    }
}

class ColorSection: BasicRecycleItem<UIColor> {
    init() {
        super.init(
            data: Util.randomColor(),
            diffableKey: { $0.description },
            cell: { o, _ in
                let w = o.contentSize.width.map { floor(($0 / 3) * 100) / 100 }
                return HBox().attach()
                    .size(w, w.map { $0 / 2 })
                    .backgroundColor(o.data)
                    .diagnosis()
                    .view
            }
        )
    }
}
