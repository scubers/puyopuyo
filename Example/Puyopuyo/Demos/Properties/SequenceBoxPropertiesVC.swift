//
//  ListBoxProperties.swift
//  Puyopuyo_Example
//
//  Created by 王俊仁 on 2020/5/18.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import Puyopuyo

class SequenceBoxPropertiesVC: BaseVC {
    let sections = State<[ISequenceSection]>([])
    override func configView() {
        vRoot.attach {
            SequenceBox(
                separatorStyle: .none,
                estimatedRowHeight: 10,
                estimatedHeaderHeight: 10,
                sections: self.sections.asOutput()
            )
            .attach($0)
            .size(.fill, .fill)
        }

        reload()
    }

    func reload() {
        sections.value = [
            BasicSequenceSection<Int>(
                id: "sldkjf",
                data: 1,
                rows: (0..<5).map {
                    BasicSequenceItem<Int>(
                        id: "sf98hsdf",
                        data: $0,
                        _cell: { o, _ in
                            ZBox().attach {
                                Label.demo("").attach($0)
                                    .text(o.map { $0.data.description })
                            }
                            .padding(all: 10)
                            .width(.fill)
                            .view
                        }
                    )
                }.asOutput(),
                _header: { _, _ in
                    HBox().attach {
                        Label.demo("single row header").attach($0)
                    }
                    .backgroundColor(UIColor.systemPink)
                    .width(.fill)
                    .view
                }
            ),
            DataSequenceSection<Int>(
                id: "pure",
                dataSource: (0..<5).map { $0 }.asOutput(),
                _cell: { o, _ in
                    HBox().attach {
                        Label.demo("").attach($0)
                            .text(o.map { $0.data.description })
                            .width(.fill)
                        Label.demo("").attach($0)
                            .text(o.map { $0.data.description })
                            .width(.fill)
                    }
                    .padding(all: 10)
                    .space(10)
                    .width(.fill)
                    .view
                },
                _header: { _, _ in
                    HBox().attach {
                        Label.demo("pure section header").attach($0)
                    }
                    .backgroundColor(UIColor.cyan)
                    .width(.fill)
                    .view
                }
            )
        ]
    }
}
