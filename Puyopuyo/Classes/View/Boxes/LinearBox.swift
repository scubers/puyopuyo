
//
//  File.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import Foundation

open class LinearBox: GenericBoxView<LinearRegulator> {
    override public func createRegulator() -> LinearRegulator {
        LinearRegulator(delegate: self, sizeDelegate: self, childrenDelegate: self)
    }
}

open class HBox: LinearBox {
    override public func createRegulator() -> LinearRegulator {
        let reg = super.createRegulator()
        reg.direction = .horizontal
        return reg
    }
}

open class VBox: LinearBox {
    override public func createRegulator() -> LinearRegulator {
        let reg = super.createRegulator()
        reg.direction = .vertical
        return reg
    }
}
