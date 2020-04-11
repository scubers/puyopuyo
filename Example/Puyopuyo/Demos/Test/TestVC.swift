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

        let text = State("")

        VBox().attach(view) {
            HBox().attach($0) {
                Label.demo("sldkfjlsdjflsdsldkfjlsdjflsdsldkfjlsdjflsdsldkfjlsdjflsd").attach($0)
                    .width(.wrap(priority: 5))
                    .text(text)

                Label.demo("我是最弱的").attach($0)
                    .height(10)
                
                Label.demo("我是最强的").attach($0)
                    .width(.wrap(priority: 10))
                
                Label.demo("我是次强的").attach($0)
                    .width(.wrap(priority: 1))
            }
            .padding(all: 10)
            .space(20)
            .width(.fill)

            UITextField().attach($0)
                .size(.fill, 20)
                .texting(text.asInput())
        }
        .space(10)
        .padding(all: 16)
        .size(.fill, .fill)

        Util.randomViewColor(view: view)
    }
}
