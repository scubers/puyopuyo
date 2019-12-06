//
//  AligmentVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/12/6.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Puyopuyo

class AligmentVC: BaseVC {

    override func configView() {
        
        UIScrollView().attach(vRoot)
            .size(.fill, .fill)
            .flatBox(.y)
//            .size(.fill, .fill)
            .attach {
            // MARK: - 水平布局JustifyContent
            Label("水平布局").attach($0)
            let justifyContent = State<Aligment>(.top)
            HBox().attach($0) {
                Label("1").attach($0)
                Label("2").attach($0)
                Label("3").attach($0)
            }
            .animator(Animators.default)
            .size(.fill, 50)
            .justifyContent(justifyContent)
            SelectionView<Aligment>([.top, .bottom, .center]).attach($0)
                .onEventProduced(justifyContent)
                .size(.fill, .wrap)
        }
    }
    
    override func shouldRandomColor() -> Bool {
        return false
    }
    
}
