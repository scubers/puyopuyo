
//
//  File.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import Foundation

open class LinearBox: GenericBoxView<LinearRegulator> {
    override public func createRegulator() -> Regulator {
        LinearRegulator(delegate: self, sizeDelegate: self, childrenDelegate: self)
    }
}

open class HBox: LinearBox {}

open class VBox: LinearBox {
    override public init(frame: CGRect) {
        super.init(frame: frame)
        attach().direction(.y)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError()
    }
}
