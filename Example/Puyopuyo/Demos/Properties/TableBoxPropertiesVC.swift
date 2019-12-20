//
//  TableBoxPropertiesVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/12/16.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Puyopuyo
import UIKit

class TableBoxPropertiesVC: BaseVC, UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("\(scrollView.contentOffset)")
    }

    var datas = State([[String]]())

    enum Event {
        case tap
    }

    override func configView() {
        TableBox<String, UIView, Event>(
            cell: { [weak self] o, i in
                guard let self = self else { fatalError() }
                return VFlow(count: 0).attach {
                    let v = $0
                    _ = o.outputing { _, idx in
                        v.subviews.forEach({ $0.removeFromSuperview() })
                        for i in 0 ..< idx.row {
                            Label.demo("demo").attach(v)
                                .text((i + idx.row).description)
                                .size(50, 50)
                        }
                    }
                }
                .space(10)
                .padding(all: 10)
                .width(.fill)
                .styles([TapRippleStyle()])
                .bottomBorder([.color(UIColor.lightGray.withAlphaComponent(0.5)), .thick(1), .lead(10), .trail(10)])
                .onTap(to: self, { _, _ in
                    i.input(value: .tap)
                })
                .view

            }, header: {
                VBox().attach {
                    Label.demo("header").attach($0)
                    Label.demo("header").attach($0)
                    Label.demo("header").attach($0)
                    Label.demo("header").attach($0)
                }
                .space(4)
                .view
            }, footer: {
                Label.demo("footer")
            }
        )
        .attach(vRoot)
        .setDelegate(self)
        .onEventProduced(to: self, { _, e in
            print("\(e.indexPath), \(e.data), \(e.eventType)")
        })
        .viewState(datas)
        .size(.fill, .fill)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        datas.value = [(0 ..< 20).map({ $0.description })]
    }
}
