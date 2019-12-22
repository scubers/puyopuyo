//
//  ListBoxPropertiesVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/12/22.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Puyopuyo
import UIKit

class ListBoxPropertiesVC: BaseVC, UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset)
    }

    var sections = State<[ListSection]>([])

    override func configView() {
        ListBox(
            tableView: {
                UITableView().attach()
                    .alwaysVertBounds(false)
                    .view
            },
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
        .viewState(sections)
        .setDelegate(self)
        .size(.fill, .fill)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let first = State((0 ..< 3).map({ $0.description }))

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            first.value = (0 ..< 16).map({ $0.description })
        }

        sections.value = [
            BasicSection<String, UIView, Void>(
                identifier: "1",
                dataSource: first,
                _cell: { [weak self] o, _ -> UIView in
                    guard let self = self else { return UIView() }
                    return self.getCell(state: o)
                },
                _header: { o, e -> UIView? in
                    HBox().attach {
                        Label.demo("").attach($0)
                            .text(o.map({ idx, _ in "header: \(idx)" }))
                    }
                    .onTap({ _ in
                        e.input(value: ())
                    })
                    .padding(all: 10)
                    .view
                },
                _footer: { o, e in
                    HBox().attach {
                        Label.demo("").attach($0)
                            .text(o.map({ idx, _ in "footer: \(idx)" }))
                    }
                    .onTap({ _ in
                        e.input(value: ())
                    })
                    .padding(all: 10)
                    .view
                },
                _event: {
                    print($0)
                }
            ),

            BasicSection<String, UIView, Void>(
                identifier: "2",
                dataSource: State((0 ..< 10).map({ $0.description })),
                _cell: { [weak self] o, _ -> UIView in
                    guard let self = self else { return UIView() }
                    return self.getCell(state: o)
                }
            ),
        ]
    }

    func getCell(state: SimpleOutput<(Int, String)>) -> UIView {
        return VFlow(count: 0).attach {
            let v = $0
            _ = state.outputing { idx, _ in
                v.subviews.forEach({ $0.removeFromSuperview() })
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
