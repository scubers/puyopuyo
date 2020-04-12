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
            ZBox().attach($0) {
                ZBox().attach($0) {
                    ZBox().attach($0) {
                        Label.demo("demo").attach($0)
                    }
                    .size(.fill, .fill)
                    .padding(all: 10)
                }
                .size(.fill, .fill)
                .padding(all: 10)
            }
            .size(.fill, .fill)
            .padding(all: 10)

//            HBox().attach($0) {
//                Label.demo("slkdjflskjdflskj").attach($0)
//                    .size(40, .wrap(add: 30))
//
//                Label.demo("1").attach($0)
//                    .alignment(.top)
//                Label.demo("2").attach($0)
//                    .alignment(.center)
//                Label.demo("3").attach($0)
//                    .alignment(.bottom)
//            }
//            .height(.wrap(add: 50))
//            .space(4)
        }
        .space(10)
        .padding(all: 16)
        .size(.fill, .fill)

        Util.randomViewColor(view: view)
    }
}
