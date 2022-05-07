//
//  ChangeNotifier.swift
//  Puyopuyo
//
//  Created by J on 2022/5/7.
//

import Foundation

public protocol ChangeNotifier {
    var changeNotifier: Outputs<Void> { get }
}

public extension ChangeNotifier where Self: AnyObject {
    var onChanged: OutputBinder<Self> {
        let this = WeakableObject(value: self)
        return changeNotifier
            .filter { this.value != nil }
            .map { this.value! }
            .binder
    }
}
