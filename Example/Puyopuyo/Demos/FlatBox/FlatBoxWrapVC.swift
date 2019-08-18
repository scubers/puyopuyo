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
    let bounds = State<CGRect>(.zero)
    
    var widthLimit: State<SizeDescription> {
        return bounds.map({ (rect) -> SizeDescription in
            return .fixed(min(200, max(50, rect.width)))
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vRoot.attach() {
            UITextField().attach($0)
                .onText(self.text)
                .size(100, 30)
            
            let bounds = State<CGRect>(.zero)
            HBox().attach($0) {
                
                Label().attach($0)
                    .numberOfLines(State(0))
                    .width(SizeDescription.follow(on: $0, { .wrap(max: $0.width * 0.8) }))
                    .height(SizeDescription.follow(on: $0, { .fixed($0.height * 0.5) }))
                    .onBoundsChanged(self.bounds)
                    .text(self.text)
            }
            .onBoundsChanged(bounds)
            .size(200, 100)
            
            Label("测试跟踪").attach($0)
                .width(self.widthLimit)
        }
        .space(8)
        .size(.fill, .fill)
        .justifyContent(.center)

        randomViewColor(view: view)
    }
}
