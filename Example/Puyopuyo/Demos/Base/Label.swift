//
//  Label.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/8/11.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Puyopuyo

extension StyleSheet {
    static var randomColorStyle: Style {
        let color = UIColor(red: CGFloat(arc4random()) / CGFloat(UInt32.max), green: CGFloat(arc4random()) / CGFloat(UInt32.max), blue: CGFloat(arc4random()) / CGFloat(UInt32.max), alpha: 1)
        return (\UIView.backgroundColor).getStyle(with: color)
    }
}

class Label: UILabel {
    convenience init(_ title: String? = nil) {
        self.init(frame: .zero)
        self.text = title
        numberOfLines = 0
        textAlignment = .center
        isUserInteractionEnabled = true
    }
    
    static func title(_ title: String) -> Label {
        return Label(title)
    }
    
    static func demo(_ title: String) -> Label {
        let l = self.title(title)
        l.layer.borderColor = Theme.color.cgColor
        l.layer.borderWidth = Util.pixel(1)
        l.attach().width(.wrap(add: 10))
        return l
    }
    
    deinit {
        print("label deinit..(\(self.text ?? ""))")
    }
}
