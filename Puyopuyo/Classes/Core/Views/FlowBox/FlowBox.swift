//
//  FlowBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/8/20.
//

import Foundation

open class FlowBox: BoxView {
    public override var layout: FlowLayout {
        return py_measure as! FlowLayout
    }
    
}
