//
//  CollectionBoxPropertiesVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/12/23.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Puyopuyo
import UIKit

class CollectionBoxPropertiesVC: BaseVC {
    override func configView() {
        CollectionBox(
            sections: [
                CollectionSection<String, UIView, Void>(
                    identifier: "1",
                    dataSource: State((0 ..< 50).map({ $0.description })),
                    _cell: { o, _ in
                        HBox().attach() {
                            Label.demo("").attach($0)
                                .text(o.map({ $1 }))
                                .height(50)
                                .width(50)
                        }
                        .bottomBorder([.color(Theme.dividerColor), .thick(0.5)])
                        .padding(all: 8)
                        .width(.fill)
                        .view
                    },
                    _event: {
                        print($0)
                    }
                ),
            ]
        )
        .attach(vRoot)
        .alwaysVertBounds(true)
        .size(.fill, .fill)
    }
}
