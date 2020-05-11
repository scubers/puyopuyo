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
                sections: self.sections.asOutput()
            )
            .attach($0)
            .size(.fill, .fill)
        }

        reload()
    }

    func reload() {
        let array = (0..<50).map { $0 }
        let section1Rows = State([IRecycleItem]())
        let section2Rows = State([IRecycleItem]())

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            section1Rows.value = (0..<10).map { v -> IRecycleItem in
                BasicRecycleItem<Int, Void>(
                    id: "1",
                    data: v,
                    differ: { $0.description },
                    _cell: { o, _ in
                        VBox().attach {
                            Label.demo("").attach($0)
                                .text(o.map { $0.data.description })
                        }
                        .margin(all: 10)
                        .borders([.color(Theme.dividerColor)])
                        .view
                    }
                )
            }
            
            section2Rows.value = (0..<200).map { v -> IRecycleItem in
                BasicRecycleItem<Int, Void>(
                    id: "2",
                    data: v,
                    differ: { $0.description },
                    _cell: { o, _ in
                        VBox().attach {
                            Label.demo("").attach($0)
                                .text(o.map { "\($0.data * 100)" })
                        }
                        .margin(all: 10)
                        .borders([.color(Theme.dividerColor)])
                        .view
                    }
                )
            }
            
        }
        sections.value = [
            BasicRecycleSection<String, Void>(
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
                enableDiff: true,
                items: section2Rows.asOutput()
            ),
        ]
    }
}
