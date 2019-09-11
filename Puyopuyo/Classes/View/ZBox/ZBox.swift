//
//  ZBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

open class ZBox: BoxView {
    public override var regulator: ZRegulator {
        return py_measure as! ZRegulator
    }
}
