//
//  Puyo+UISlider.swift
//  Puyopuyo
//
//  Created by 王俊仁 on 2020/3/22.
//

import Foundation

public extension Puyo where T: UISlider {
    @discardableResult
    func value<O: Outputing>(_ value: O) -> Self where O.OutputType == Float {
        value.asOutput().distinct().safeBind(to: view) { v, s in
            v.value = s
        }
        return self
    }
}
