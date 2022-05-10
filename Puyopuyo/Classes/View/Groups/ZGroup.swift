//
//  ZGroup.swift
//  Puyopuyo
//
//  Created by J on 2022/5/2.
//

import Foundation

// MARK: - ZGroup

public class ZGroup: GenericBoxGroup<ZRegulator> {
    override public func createRegulator() -> ZRegulator {
        ZRegulator(delegate: self, sizeDelegate: nil, childrenDelegate: self)
    }
}
