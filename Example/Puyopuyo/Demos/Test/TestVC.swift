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
            VBox().attach($0) {
                Label.demo(".fix(100)").attach($0)
                    .width(.fix(100))
                    .height(30)
                Label.demo(".ratio(1)").attach($0)
                    .width(.ratio(1))
                    .height(30)
                Label.demo(".wrap()").attach($0)
                    .width(.wrap)
                    .height(30)
                Label.demo(".wrap(add: 10)").attach($0)
                    .width(.wrap(add: 10))
                    .height(30)
                Label.demo(".wrap(add: 10, min: 20, max: 50)").attach($0)
                    .width(.wrap(add: 10, min: 20, max: 100))
                    .height(30)
            }
            .space(2)
            .padding(all: 10)
            .size(.fill, .wrap)
            .animator(Animators.default)
        }
        .space(10)
        .padding(all: 16)
        .size(.fill, .fill)

        Util.randomViewColor(view: view)
    }
}
