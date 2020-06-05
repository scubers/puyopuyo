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
                sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10),
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
            BasicRecycleItem<Int>(
//                id: "1",
                data: v,
                differ: { $0.description },
                _cell: { o, i in
                    VBox().attach {
                        Label.demo("").attach($0)
                            .text(o.map { $0.data.description })
                            .size(50, 50)
                    }
                    .padding(all: 10)
                    .onTap { _ in
                        i.withContext { print("small item: \($0.data)") }
                    }
                    .borders([.color(Theme.dividerColor)])
                    .view
                }
            )
        }
    }

    func getBigItems(start: Int = 0, count: Int) -> [IRecycleItem] {
        (start..<start + count).map { v -> IRecycleItem in
            BasicRecycleItem<Int>(
//                id: "2",
                data: v,
                differ: { $0.description },
                _cell: { o, i in
                    VBox().attach {
                        Label.demo("").attach($0)
                            .text(o.map { "\($0.data * 100)" })
                            .size(60, 60)
                    }
                    .padding(all: 10)
                    .borders([.color(Theme.dividerColor)])
                    .onTap { _ in
                        i.withContext { print("big item: \($0.data)") }
                    }
                    .view
                },
                _didSelect: {
                    print($0)
                }
            )
        }
    }

    func reload() {
        let section1Rows = State([IRecycleItem]())
        let section2Rows = State([IRecycleItem]())

        let sections1 = (0..<10).map { (idx) -> IRecycleSection in
            RecycleSection<Int, Int>(
//                id: "slkdjfl",
                sectionData: idx,
                list: (0..<(idx * 5)).map { $0 * 10 }.asOutput(),
                _cell: { o, _ in
                    ZBox().attach {
                        Label.demo("").attach($0)
                            .text(o.map { $0.data.description })
                    }
                    .view
                },
                _header: { o, i in
                    HBox().attach {
                        Label.demo("").attach($0)
                            .text(o.map { "header: \($0.data + 1)" })
                    }
                    .onTap { _ in
                        i.withContext { print("header tap data: \($0.data), index: \($0.indexPath)") }
                    }
                    .view
                }
            )
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            section1Rows.value = self.getSmallItems(count: 10)
            section2Rows.value = self.getBigItems(count: 20)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                section1Rows.value = self.getSmallItems(start: 5, count: 10)
                section2Rows.value = self.getBigItems(start: 10, count: 20)
            }
        }
        sections.value = [
            BasicRecycleSection<String>(
                data: "header1",
                items: [
                    BasicRecycleItem<Int>(
//                        id: "a",
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
                    BasicRecycleItem<Int>(
//                        id: "b",
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
            DataRecycleSection<Int>(
//                id: "lskdjfdd",
                itemSpacing: 10,
                list: (0..<10).map { $0 }.asOutput(),
                _cell: { o, i in
                    VBox().attach {
                        Label.demo("").attach($0)
                            .text(o.map { $0.data.description })
                        Label.demo("").attach($0)
                            .text(o.map { $0.data.description })
                        Label.demo("").attach($0)
                            .text(o.map { $0.data.description })
                    }
                    .onTap { _ in
                        i.withContext { print($0.data) }
                    }
                    .view
                },
                _header: { _, i in
                    HBox().attach {
                        Label.demo("header").attach($0)
                    }
                    .backgroundColor(UIColor.systemPink)
                    .onTap { _ in
                        i.withContext { _ in print("------") }
                    }
                    .view
                },
                _didSelect: {
                    print($0)
                }
            ),
            BasicRecycleSection<String>(
//                id: "sldkjf",
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
            BasicRecycleSection<String?>(
                insets: UIEdgeInsets(top: 40, left: 30, bottom: 20, right: 10),
                lineSpacing: 10,
                itemSpacing: 20,
                data: nil,
                items: section2Rows.asOutput()
            ),
        ] + sections1
    }
}
