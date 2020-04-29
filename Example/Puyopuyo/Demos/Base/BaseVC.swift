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

class BaseVC: UIViewController, UIScrollViewDelegate {
    var navState = State(NavigationBox.ViewState())
    var navHeight = State<SizeDescription>(.fix(44))

    override func loadView() {
        super.loadView()
        NavigationBox(
            navBar: {
                NavBar(title: "\(type(of: self))").attach()
                    .height(self.navHeight)
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
        .attach(view)
        .size(.fill, .fill)
        .viewState(navState)
        
        navState.value.shadowOpacity = 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
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

    deinit {
        print("\(self) deinit!!!")
    }
    
    override var canBecomeFirstResponder: Bool { true }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        becomeFirstResponder()
    }
}
