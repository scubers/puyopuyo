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
                ZBox().attach($0)
                    .padding(all: 20)
                    .size(.fill, 50)
                
//                NavBar(title: "\(type(of: self))").attach($0)
//                    .onEventProduced(to: self) { s, e in
//                        if e == .tapLeading {
//                            s.navigationController?.popViewController(animated: true)
//                        }
//                }
            }
            .padding(all: 10)
            .size(.fill, .wrap)
//            ZBox().attach($0) {
//                Label.demo("slkdjfldkjf").attach($0)
//                    .alignment(.bottom)
//            }
//            .padding(all: 10)
//            .size(.fill, .wrap)
        }
        .padding(all: 16)
        .size(.fill, .fill)

        Util.randomViewColor(view: view)
    }
}
