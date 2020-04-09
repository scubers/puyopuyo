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

        ZBox().attach(view) {
            UIView().attach($0) {
                VBox().attach($0)
                    .margin(all: -10)
                    .size(.fill, .fill)
            }
            .size(100, 100)
//            VFlow(count: 3).attach($0) {
//                for i in 0..<4 {
//                    Label.demo((i + 1).description).attach($0)
//                        .size(50, 50)
//                }
//            }
//            .space(10)
//            .reverse(true)
//            .padding(all: 10)
//            .size(.fill, .fill)
        }
        .justifyContent(.top)
        .padding(all: 16)
        .size(.fill, .fill)

        Util.randomViewColor(view: view)
    }
}
