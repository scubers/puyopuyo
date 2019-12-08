
//
//  File.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import Foundation

open class FlatBox: BoxView {
    public override var regulator: FlatRegulator {
        return py_measure as! FlatRegulator
    }
}

open class HBox: FlatBox {}

open class VBox: FlatBox {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        regulator.direction = .y
    }

    public required init?(coder _: NSCoder) {
        fatalError()
    }
}
