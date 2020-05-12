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
                estimatedSize: .init(width: 1, height: 1),
                enableDiff: true,
                sections: self.sections.asOutput()
            )
            .attach($0)
            .size(.fill, .fill)
        }

        reload()
    }

    func getSmallItems(start: Int = 0, count: Int) -> [IRecycleItem] {
        (start..<start + count).map { v -> IRecycleItem in
            BasicRecycleItem<Int, Void>(
                id: "1",
                data: v,
                differ: { $0.description },
                _cell: { o, _ in
                    VBox().attach {
                        Label.demo("").attach($0)
                            .text(o.map { $0.data.description })
                            .size(50, 50)
                    }
                    .padding(all: 10)
                    .borders([.color(Theme.dividerColor)])
                    .view
                }
            )
        }
    }

    func getBigItems(start: Int = 0, count: Int) -> [IRecycleItem] {
        (start..<start + count).map { v -> IRecycleItem in
            BasicRecycleItem<Int, Void>(
                id: "2",
                data: v,
                differ: { $0.description },
                _cell: { o, _ in
                    VBox().attach {
                        Label.demo("").attach($0)
                            .text(o.map { "\($0.data * 100)" })
                            .size(60, 60)
                    }
                    .padding(all: 10)
                    .borders([.color(Theme.dividerColor)])
                    .view
                }
            )
        }
    }

    func reload() {
        let section1Rows = State([IRecycleItem]())
        let section2Rows = State([IRecycleItem]())

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            section1Rows.value = self.getSmallItems(count: 10)
            section2Rows.value = self.getBigItems(count: 20)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                section1Rows.value = self.getSmallItems(start: 5, count: 10)
                section2Rows.value = self.getBigItems(start: 10, count: 20)
            }
        }
        sections.value = [
            BasicRecycleSection<String, Void>(
                data: "header1",
                items: [
                    BasicRecycleItem<Int, Void>(
                        id: "a",
                        data: 1,
                        _cell: { o, _ in
                            HBox().attach {
                                Label.demo("").attach($0)
                                    .text(o.map { $0.data.description })
                                Label.demo("").attach($0)
                                    .text(o.map { $0.data.description })
                            }
                            .view
                        }
                    ),
                    BasicRecycleItem<Int, Void>(
                        id: "b",
                        data: 2,
                        _cell: { o, _ in
                            VBox().attach {
                                Label.demo("").attach($0)
                                    .text(o.map { $0.data.description })
                                Label.demo("").attach($0)
                                    .text(o.map { $0.data.description })
                            }
                            .view
                        }
                    ),
                ].asOutput()
            ),
            BasicRecycleSection<String, Void>(
                id: "sldkjf",
                insets: UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40),
                data: "header",
                items: section1Rows.asOutput(),
                _header: { o, _ in
                    HBox().attach {
                        Label.demo("").attach($0)
                            .text(o.map { "\($0.data)" })
                    }
                    .backgroundColor(UIColor.cyan)
                    .width(.fill)
                    .view
                }
            ),
            BasicRecycleSection<String?, Void>(
                insets: UIEdgeInsets(top: 40, left: 30, bottom: 20, right: 10),
                lineSpacing: 10,
                itemSpacing: 20,
                data: nil,
                items: section2Rows.asOutput()
            ),
        ]
    }
}
