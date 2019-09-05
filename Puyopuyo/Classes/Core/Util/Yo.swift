//
//  Yo.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/6.
//

import Foundation

public struct Yo<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol PuyoExt {
    associatedtype PuyoExtType
    var yo: PuyoExtType {get}
}

extension PuyoExt {
    public var yo: Yo<Self> {
        return Yo(self)
    }
}
