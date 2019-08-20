//
//  VBoxVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/8/11.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Puyopuyo

class VBoxVC: BaseVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "VBox,space=10,padding=10"
        
        VBox().attach(vRoot) {
            Label("""
                    aligment = left
                    width = .wrap add 20
                    height = 100
                    """).attach($0)
                .size(.wrap(add: 20), 100)
            
            Label("""
                    aligment = right
                    width = .wrap add 50
                    height = 200
                    """).attach($0)
                .aligment(.right)
                .size(.wrap(add: 50), 200)
            
            Label("""
                    aligment = center
                    width = .wrap add 80
                    height = wrap
                    """).attach($0)
                .aligment(.center)
                .size(.wrap(add: 80), .wrap)
        }
        .space(10)
        .size(.fill, .fill)
        .padding(all: 10)
        
        randomViewColor(view: view)
        
    }
}
