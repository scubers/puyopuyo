//
//  BaseVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/6/30.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Puyopuyo

class BaseVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isTranslucent = false
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back", style: .plain, target: self, action: #selector(BaseVC.back))
        vRoot.attach(view).size(.ratio(1), .ratio(1))
        configView()
        Util.randomViewColor(view: view)
    }
    
    var vRoot: VBox = VBox()
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    
    func configView() {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
