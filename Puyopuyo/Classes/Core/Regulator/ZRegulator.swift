//
//  ZLayout.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

public class ZRegulator: Regulator {
    override public func calculate(by size: CGSize) -> CGSize {
        return ZCalculator(self, residual: size).calculate()
    }
}
