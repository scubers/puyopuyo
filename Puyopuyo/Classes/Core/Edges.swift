//
//  Edges.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import Foundation

/**
 逆时针计算一个四周
 布局开始方向 = start，相反 = end
 从start逆时针到end的边为forwarding，相反 = backwarding
 */
public struct Edges {
    
    public var start: CGFloat = 0
    public var end: CGFloat = 0
    public var forward: CGFloat = 0
    public var backward: CGFloat = 0
    
    public init(start: CGFloat = 0, end: CGFloat = 0, forward: CGFloat = 0, backward: CGFloat = 0) {
        self.start = start
        self.end = end
        self.forward = forward
        self.backward = backward
    }
}
