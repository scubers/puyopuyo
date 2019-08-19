//
//  Util.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/8/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

struct Util {
    static func randomColor() -> UIColor {
        let red = CGFloat(arc4random()%256)/255.0
        let green = CGFloat(arc4random()%256)/255.0
        let blue = CGFloat(arc4random()%256)/255.0
        let c = UIColor(red: red, green: green, blue: blue, alpha: 0.7)
        return c
    }
    
    
    static func randomViewColor(view: UIView) {
        view.subviews.forEach { (v) in
            v.backgroundColor = self.randomColor()
            self.randomViewColor(view: v)
        }
    }

    static func random<T>(array: [T]) -> T {
        let index = arc4random_uniform(UInt32(array.count))
        return array[Int(index)]
    }
}
