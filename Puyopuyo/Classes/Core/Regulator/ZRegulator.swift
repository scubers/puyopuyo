//
//  ZLayout.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

public class ZRegulator: Regulator {
    override public func calculate(by residual: CGSize) -> CGSize {
        return ZCalculator().calculate(self, residual: residual)
    }
}
