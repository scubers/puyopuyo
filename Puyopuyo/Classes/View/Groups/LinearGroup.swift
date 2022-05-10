//
//  LinearGroup.swift
//  Puyopuyo
//
//  Created by J on 2022/5/2.
//

import Foundation

// MARK: - LinearGroup

public class LinearGroup: GenericBoxGroup<LinearRegulator> {
    override public func createRegulator() -> LinearRegulator {
        LinearRegulator(delegate: self, sizeDelegate: nil, childrenDelegate: self)
    }
}

public class HGroup: LinearGroup {
    override public func createRegulator() -> LinearRegulator {
        let reg = super.createRegulator()
        reg.direction = .horizontal
        return reg
    }
}

public class VGroup: LinearGroup {
    override public func createRegulator() -> LinearRegulator {
        let reg = super.createRegulator()
        reg.direction = .vertical
        return reg
    }
}
