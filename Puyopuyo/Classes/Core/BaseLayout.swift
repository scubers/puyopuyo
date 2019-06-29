//
//  BaseLayout.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

public enum Formation {
    case leading
    case center
    case sides
    case trailing
}

/// 描述一个布局具备控制子节点的属性
public class BaseLayout: Measure {
    
    public var justifyContent: Aligment = .center
    
    public var padding = UIEdgeInsets.zero
    
    public var children: [Measure] {
        return target?.py_children ?? []
    }
    
    public func getCalPadding() -> CalEdges {
        return CalEdges(insets: padding, direction: direction)
    }
}
