
//
//  File.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import Foundation

open class FlatBox: BoxView {
    
    public override var layout: FlatLayout {
        return py_measure as! FlatLayout
    }
    
}

open class HBox: FlatBox {
}

open class VBox: FlatBox {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        layout.direction = .y
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

