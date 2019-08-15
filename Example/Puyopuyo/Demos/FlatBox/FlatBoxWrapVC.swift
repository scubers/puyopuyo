//
//  VBoxAutoSquareVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/8/11.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Puyopuyo

class FlatBoxWrapVC: BaseVC {
    
    let text = State<String?>(nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vRoot.attach() {
            UITextField().attach($0)
                .onText(self.text)
                .size(100, 30)
            
            HBox().attach($0) {
                Label().attach($0)
                    .numberOfLines(State(0))
                    .text(self.text)
            }
            .size(200, 100)
        }
        .space(8)
        .size(.fill, .fill)
        .justifyContent(.center)

        randomViewColor(view: view)
    }
}
