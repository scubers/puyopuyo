//
//  ZBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

open class ZBox: BoxView<ZRegulator> {
    override public func createRegulator() -> Regulator {
        ZRegulator(delegate: self, sizeDelegate: self, childrenDelegate: self)
    }
}
