//
//  ShadowStyle.swift
//  Puyopuyo_Example
//
//  Created by J on 2021/8/12.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import Puyopuyo

class ShadowStyle: Style {
    func apply(to decorable: Decorable) {
        if let view = decorable as? UIView {
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOffset = CGSize(width: 5, height: 5)
            view.layer.shadowOpacity = 0.3
            view.layer.shadowRadius = 4
        }
    }
}
