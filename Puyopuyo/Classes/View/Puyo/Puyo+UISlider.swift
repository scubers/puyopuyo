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
        bind(keyPath: \T.value, value)
    }
}
