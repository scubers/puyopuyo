//
//  VBoxAutoSquareVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/8/11.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Puyopuyo

class VBoxAutoSquareVC: BaseVC {
    

    let height = State<SizeDescription>(.fixed(100))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        HBox().attach(vRoot) {
            UIView().attach($0)
                .size(self.height, self.height)
        }
        .width(.fill)
        .height(self.height)
//        .size(.fill, self.height)
        
    }
}
