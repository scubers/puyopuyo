//
//  SpecificValuable.swift
//  Puyopuyo
//
//  Created by J on 2021/9/24.
//

import Foundation

public protocol SpecificValueable: AnyObject {
    associatedtype SpecificValue
    var specificValue: SpecificValue { get set }
}
