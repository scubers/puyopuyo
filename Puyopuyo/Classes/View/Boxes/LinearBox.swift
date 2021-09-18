
//
//  File.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import Foundation

open class LinearBox: BoxView<LinearRegulator> {}

open class HBox: LinearBox {}

open class VBox: LinearBox {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        attach().direction(.y)
    }

    public required init?(coder _: NSCoder) {
        fatalError()
    }
}
