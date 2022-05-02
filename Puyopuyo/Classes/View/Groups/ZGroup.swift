//
//  ZGroup.swift
//  Puyopuyo
//
//  Created by ByteDance on 2022/5/2.
//

import Foundation

// MARK: - ZGroup

public class ZGroup: GenericVirtualGroup<ZRegulator> {
    override public func createRegulator() -> ZRegulator {
        ZRegulator(delegate: self, sizeDelegate: nil, childrenDelegate: self)
    }
}
