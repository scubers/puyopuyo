//
//  UniqueOutputable.swift
//  Puyopuyo
//
//  Created by J on 2021/8/24.
//

import Foundation

public protocol UniqueOutputable: AnyObject {
    var uniqueDisposable: Disposable? { get set }
}

public extension Outputing where Self: UniqueOutputable {
    func uniqueOutput(_ output: @escaping (OutputType) -> Void) -> Disposable {
        uniqueDisposable?.dispose()
        let disposable = outputing(output)
        uniqueDisposable = disposable
        return disposable
    }
}
