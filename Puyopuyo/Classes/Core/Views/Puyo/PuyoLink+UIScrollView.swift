//
//  Puyo+UIScrollView.swift
//  Puyopuyo
//
//  Created by Junren Wong on 2019/8/2.
//

import Foundation

extension Puyo where T: UIScrollView {
    @discardableResult
    public func vertBounds(_ value: Bool) -> Self {
        view.bounces = value
        return self
    }
    
    @discardableResult
    public func alwaysVertBounds(_ value: Bool) -> Self {
        view.alwaysBounceVertical = value
        return self
    }
    
    @discardableResult
    public func horzBounds(_ value: Bool) -> Self {
        view.bounces = value
        return self
    }
    
    @discardableResult
    public func alwaysHorzBounds(_ value: Bool) -> Self {
        view.alwaysBounceHorizontal = value
        return self
    }
    
}
