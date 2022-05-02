//
//  LinearGroup.swift
//  Puyopuyo
//
//  Created by ByteDance on 2022/5/2.
//

import Foundation

// MARK: - LinearGroup

public class LinearGroup: GenericVirtualGroup<LinearRegulator> {
    override public func createRegulator() -> LinearRegulator {
        LinearRegulator(delegate: self, sizeDelegate: nil, childrenDelegate: self)
    }
}

public class HGroup: LinearGroup {
    override public init() {
        super.init()
        regulator.direction = .horizontal
    }
}

public class VGroup: LinearGroup {
    override public init() {
        super.init()
        regulator.direction = .vertical
    }
}
