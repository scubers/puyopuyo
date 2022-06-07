//
//  DropDownableView.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/5/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//


import UIKit

class DropDownableView: HBox, Stateful {
    let state = State<String>("")

    override func buildBody() {
        attach {
            UILabel().attach($0)
                .textColor(UIColor.label)
                .text(state)
                .fontSize(16)

            UIImageView().attach($0)
                .width(.wrap(priority: 10))
                .image(UIImage(systemName: "arrowtriangle.down.fill"))
                .size(12, 10)
        }
        .space(4)
        .justifyContent(.center)
    }
}
