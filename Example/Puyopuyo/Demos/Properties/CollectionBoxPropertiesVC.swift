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
        let state1 = State((0 ..< 5).map { $0.description })
        let state2 = State((0 ..< 100).map { $0.description })
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            state.input(value: [])
            state1.input(value: [1, 2, 3, 4, 0].map { $0.description })
//            state2.input(value: [0, 1, 6, 7, 4, 3, 9].map({ $0.description }))
        }
        CollectionBox(
            estimatedSize: .init(width: 1, height: 1),
            minimumLineSpacing: 50,
            minimumInteritemSpacing: 50,
            pinHeader: true,
            sections: [
                CollectionSection<String, UIView, Void>(
                    identifier: "1",
                    dataSource: state1.asOutput(),
                    minLineSpacing: 10,
                    minInteractSpacing: 20,
                    insets: UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 40).asOutput(),
                    _diffIdentifier: { $0 },
                    _cell: { o, _ in
                        HBox().attach {
                            Label.demo("").attach($0)
                                .text(o.map { $0.data })
                                .height(50)
                                .width(50)
                        }
                        .bottomBorder([.color(Theme.dividerColor), .thick(0.5)])
                        .padding(all: 8)
                        .width(.fill)
                        .view
                    },
                    _cellUpdater: { _, _, ctx in
                        print("----------------\(ctx.index)")
                    },
                    _event: {
                        print($0)
                    },
                    _onEvent: {
                        print($0)
                    }
                ),
                CollectionSection<String, UIView, Void>(
                    identifier: "2",
                    dataSource: state2.asOutput(),
                    minLineSpacing: 20,
                    minInteractSpacing: 30,
                    insets: UIEdgeInsets(top: 10, left: 50, bottom: 10, right: 10).asOutput(),
//                    _itemSize: { _, _ in
//                        return CGSize(width: 20, height: 20)
//                    },
                    _diffIdentifier: { $0 },
                    _cell: { o, _ in
                        HBox().attach {
                            Label.demo("").attach($0)
                                .text(o.map { $0.data })
                                .height(simulate: Simulate.ego.width)
//                                .height(50)
//                                .width(50)
                        }

                        .padding(all: 8)
                        .view
                    },
                    _header: { _, _ in
                        HBox().attach {
                            Label.demo("header").attach($0)
                        }
                        .format(.center)
                        .backgroundColor(UIColor.white)
                        .padding(all: 10)
                        .size(.fill, .wrap)
                        .view
                    },
                    _footer: { _, _ in
                        HBox().attach {
                            Label.demo("footer").attach($0)
                        }
                        .format(.center)
                        .padding(all: 10)
                        .size(.fill, .wrap)
                        .view
                    },
                    _event: {
                        print($0)
                    }
                ),
                CollectionSection<String, UIView, Void>(
                    identifier: "3",
                    dataSource: state2.asOutput(),
                    _diffIdentifier: { $0 },
                    _cell: { o, _ in
                        HBox().attach {
                            Label.demo("").attach($0)
                                .text(o.map { $0.data })
                                .height(50)
                                .width(50)
                        }
                        .padding(all: 8)
                        .view
                    },
                    _header: { _, _ in
                        HBox().attach {
                            Label.demo("header").attach($0)
                        }
                        .format(.center)
                        .backgroundColor(UIColor.white)
                        .padding(all: 10)
                        .size(.fill, .wrap)
                        .view
                    },
                    _footer: { _, _ in
                        HBox().attach {
                            Label.demo("footer").attach($0)
                        }
                        .format(.center)
                        .padding(all: 10)
                        .size(.fill, .wrap)
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
