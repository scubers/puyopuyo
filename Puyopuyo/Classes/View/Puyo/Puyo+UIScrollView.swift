//
//  Puyo+UIScrollView.swift
//  Puyopuyo
//
//  Created by Junren Wong on 2019/8/2.
//

import Foundation

extension Puyo where T: UIScrollView {
    @discardableResult
    public func bounces<O: Outputing>(_ value: O) -> Self where O.OutputType == Bool {
        value.safeBind(to: view, id: #function) { (v, a) in
            v.bounces = a
        }
        return self
    }
    
    @discardableResult
    public func alwaysVertBounds<O: Outputing>(_ value: O) -> Self where O.OutputType == Bool {
        value.safeBind(to: view, id: #function) { (v, a) in
            v.alwaysBounceVertical = a
        }
        return self
    }
    
    @discardableResult
    public func alwaysHorzBounds<O: Outputing>(_ value: O) -> Self where O.OutputType == Bool {
        value.safeBind(to: view, id: #function) { (v, a) in
            v.alwaysBounceHorizontal = a
        }
        return self
    }
    
}
