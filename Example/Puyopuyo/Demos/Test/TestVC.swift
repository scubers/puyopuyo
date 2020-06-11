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
                for idx in 0..<20 {
                    UIView().attach($0)
                        .size(50, 50)
                        .attach {
                            if idx == 1 {
                                $0.attach().flowEnding(true)
                            }
                    }
                }
            }
            .space(10)
            .size(.fill, .fill)
        }
        .space(10)
        .padding(all: 20)
        .size(.fill, .fill)
        view.backgroundColor = .white
        Util.randomViewColor(view: view)
    }

    func build() {
        attach {
            UIView().attach($0) {
                UILabel().attach($0)
                    .text("测试Label")
                UIButton().attach($0)
                    .text("测试Button", state: .normal)
            }
        }
    }
}
