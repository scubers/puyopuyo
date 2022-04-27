//
//  Calculator.swift
//  Puyopuyo
//
//  Created by J on 2022/3/29.
//

import Foundation

public protocol Calculator {
    var calculateChildrenImmediately: Bool { get }
    func calculate(_ measure: Measure, layoutResidual: CGSize) -> CGSize
}
