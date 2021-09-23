//
//  SpecificValuable.swift
//  Puyopuyo
//
//  Created by J on 2021/9/24.
//

import Foundation

public protocol SpecificValueable {
    associatedtype SpecificValue
    var specificValue: SpecificValue { get }
}
