//
//  ListBoxVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/7/2.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Puyopuyo

class ListBoxVC: BaseVC {
    
    var state = State([["String"]])
    
    class MyView: FlatBox {
        
        var text = State<String?>("empty")
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            attach() {
                UILabel().attach($0)
                    .text(self.text)
            }
        }
        required init?(coder aDecoder: NSCoder) {
            fatalError()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        vRoot.attach() {
            self.getLabel("title").attach($0)
            ListBox<MyView, String>(data: self.state).attach($0)
                .size(.ratio(1), .ratio(1))
        }
        .size(.ratio(1), .ratio(1))
        
        
        state.value = [Array(repeating: "111", count: 10)]
        
        
    }
}
