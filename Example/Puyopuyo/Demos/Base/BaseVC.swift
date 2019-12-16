//
//  BaseVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/6/30.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Puyopuyo
import UIKit

class Theme {
    static let color = UIColor.systemPink
    static let dividerColor = UIColor.black.withAlphaComponent(0.2)
}

class BaseVC: UIViewController {
    var navState = State(NavigationBox.ViewState())

    override func loadView() {
        view = NavigationBox(
            navBar: {
                NavBar(title: "\(type(of: self))").attach()
                    .onEventProduced(to: self, { s, e in
                        if e == .tapLeading {
                            s.navigationController?.popViewController(animated: true)
                        }
                    })
                    .view
            }, body: {
                self.vRoot
            }
        )
        .attach()
        .viewState(navState)
        .view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isTranslucent = false
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back", style: .plain, target: self, action: #selector(BaseVC.back))
//        vRoot.attach(view).size(.ratio(1), .ratio(1))
        configView()
        if shouldRandomColor() {
            Util.randomViewColor(view: view)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    func shouldRandomColor() -> Bool {
        return false
    }

    var vRoot: VBox = VBox()

    @objc func back() {
        navigationController?.popViewController(animated: true)
    }

    func configView() {}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
