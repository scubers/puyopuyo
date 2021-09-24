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

    override func configView() {
        vRoot.attach {
            RecycleBox(
                pinHeader: true,
                sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10),
                diff: true,
                sections: sections.asOutput()
            )
            .attach($0)
            .size(.fill, .fill)
        }

//        reloadWithMultipleSectionAnimationSeparated()
        reloadMultipleSectionToOne()
    }

    func reloadMultipleSectionToOne() {
        let dataSource = State([(0..<5).map { $0 }, (5..<10).map { $0 }])

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            dataSource.value = [(0..<10).map { $0 }]
        }

        dataSource.map { sections -> [IRecycleSection] in
            sections.map { rows in
                BasicRecycleSection(
                    data: (),
                    items: rows.map { row in
                        BasicRecycleItem(
                            data: row,
                            differ: { $0.description },
                            cell: { o, _ in
                                Cell().attach()
                                    .viewState(o.data)
                                    .view
                            }
                        )

                    }.asOutput()
                )
            }
        }
        .send(to: sections)
        .dispose(by: self)
    }

    func reloadWithMultipleSectionAnimationSeparated() {
        let section1 = State((0..<5).map { $0 })
        let section2 = State((6..<10).map { $0 })

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            section1.value = (4..<10).map { $0 }
            section2.value = (4..<20).map { $0 }
        }

        sections.value = [
            DataRecycleSection(
                items: section1.asOutput(),
                differ: { $0.description },
                cell: { o, _ in
                    Cell().attach()
                        .viewState(o.data)
                        .view
                }
            ),
            DataRecycleSection(
                items: section2.asOutput(),
                differ: { $0.description },
                cell: { o, _ in
                    Cell().attach()
                        .viewState(o.data)
                        .view
                }
            ),
        ]
    }
}

private class Cell: HBox, Stateful {
    var viewState = State<Int>.unstable()

    override func buildBody() {
        attach {
            Label.demo("").attach($0)
                .text(binder.description)
                .size(.wrap(min: 50), .wrap(min: 50))
        }
        .padding(all: 10)
    }
}
