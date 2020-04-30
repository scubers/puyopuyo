//
//  ListBoxPropertiesVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/12/22.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Puyopuyo
import UIKit

class TableBoxPropertiesVC: BaseVC, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        [
            UITableViewRowAction(style: .normal, title: "1", handler: { _, _ in

            }),
            UITableViewRowAction(style: .default, title: "2", handler: { _, _ in

            }),
            UITableViewRowAction(style: .destructive, title: "3", handler: { _, _ in

            }),
        ]
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    var sections = State<[TableBoxSection]>([])

    override func configView() {
        TableBox(
            separatorStyle: .none,
            header: {
                VBox().attach {
                    Label.demo("table Header").attach($0)
                }
                .padding(all: 10)
                .view
            },
            footer: {
                VBox().attach {
                    Label.demo("table footer").attach($0)
                }
                .padding(all: 20)
                .view
            }
        )
        .attach(vRoot)
        .backgroundColor(UIColor.clear)
        .viewState(sections)
        .setDelegate(self)
        .setDataSource(self)
        .size(.fill, .fill)
        .attach { v in
            v.contentInset.top = 0
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let first = State([0, 1, 2].map { $0.description })

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            first.value = (0 ..< 16).map({ $0.description })
            first.value = [0, 4, 2, 6, 1].map { $0.description }
        }

        sections.value = [
            TableSection<String, UIView, Double>(
                identifier: "1",
                selectionStyle: .none,
                dataSource: first.asOutput(),
                _diffIdentifier: { $0 },
                _cell: { [weak self] o, _ -> UIView in
                    guard let self = self else { return UIView() }
                    return self.getCell(state: o.map { ($0.index, $0.data) })
                        .attach()
                        .view
                },
                _cellUpdater: { _, _, ctx in
                    print(ctx.index)
                },
                _header: { o, _ -> UIView? in
                    HBox().attach {
                        Label.demo("").attach($0)
                            .text(o.map { "header: \($0.index)" })
                    }
                    .backgroundColor(UIColor.white)
                    .onTap { _ in
                    }
                    .padding(all: 10)
                    .view
                },
                _footer: { o, _ in
                    HBox().attach {
                        Label.demo("").attach($0)
                            .text(o.map { "footer: \($0.index)" })
                    }
                    .backgroundColor(UIColor.white)
                    .onTap { _ in
//                        e.input(value: ())
                    }
                    .padding(all: 10)
                    .view
                },
                _event: {
                    print($0)
                },
                _onEvent: { ctx in
                    print(ctx)
                }
            ),

            TableSection<Int, UIView, Int>(
                identifier: "1",
                selectionStyle: .gray,
                dataSource: (0 ..< 10).map { $0 }.asOutput(),
                _cell: { [weak self] o, _ -> UIView in
                    guard let self = self else { return UIView() }
                    return self.getCell(state: o.map { ($0.index, $0.data.description) })
                }
            ),
        ]
    }

    func getCell(state: SimpleOutput<(Int, String)>) -> UIView {
        return VFlow(count: 0).attach {
            let v = $0
            _ = state.outputing { idx, s in
                v.subviews.forEach { $0.removeFromSuperview() }
                Label.demo(s).attach(v)
                for i in 1 ... idx + 1 {
                    Label.demo("demo").attach(v)
                        .text(i.description)
                        .size(50, 50)
                }
            }
        }
        .space(4)
        .bottomBorder([.color(Theme.dividerColor), .thick(0.5), .lead(8)])
        .padding(all: 8)
        .width(.fill)
        .view
    }
}
