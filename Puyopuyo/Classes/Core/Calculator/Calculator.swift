//
//  Calculator.swift
//  Puyopuyo
//
//  Created by J on 2022/3/29.
//

import Foundation

protocol Calculator {
    func calculate(_ measure: Measure, residual: CGSize) -> CGSize
}
