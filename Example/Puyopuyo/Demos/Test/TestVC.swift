//
//  TestVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/8/18.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Puyopuyo
import RxSwift
import TangramKit
import UIKit

class NewView: ZBox, Eventable {
    var eventProducer = SimpleIO<String>()
    override func buildBody() {
        attach {
            UIButton(type: .contactAdd).attach($0)
                .bind(to: self, event: .touchUpInside, action: { this, _ in
                    this.emmit("100")
                })
        }
    }
}

class TestVC: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isTranslucent = false

        VBox().attach(view) {
            VFlow(count: 0).attach($0) {
                for i in 0..<6 {
                    Label.demo((i + 1).description).attach($0)
                        .width(.wrap(add: 20))
                }
            }
            .space(10)
            .padding(all: 10)
            .size(.fill, .wrap)
//
//            let margin = State<CGFloat>(0)
//            DemoView<CGFloat>(
//                title: "margin",
//                builder: {
//                    HBox().attach($0) {
//                        //                    Label.demo("1").attach($0)
//                        //                    Label.demo("2").attach($0)
//                        //                    Label.demo("3").attach($0)
//                        UIView().attach($0)
//                            .size(.fill, .fill)
//                            .style(StyleSheet.randomColorStyle)
//                            .margin(margin.asOutput().map { UIEdgeInsets(top: $0, left: $0, bottom: $0, right: $0) })
//                    }
//                    .justifyContent(.center)
//                    .size(.fill, 100)
//                    .animator(Animators.default)
//                    .view
//                },
//                selectors: [0, 10, 20, 30, 40].map { Selector(desc: "\($0)", value: $0) },
//                desc: "布局系统内，子view的外边局"
//            )
//            .attach($0)
//            .onEventProduced(to: self) { _, x in
//                margin.value = x
//            }
        }
        .padding(all: 10)
        .size(.fill, .fill)
        .margin(all: 40)

        Util.randomViewColor(view: view)
    }
}
