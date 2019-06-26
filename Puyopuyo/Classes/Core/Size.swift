//
//  Size.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import Foundation

public enum SizeType {
    // 固有尺寸
    case fixed(CGFloat)
    // 依赖父视图
    case ratio(CGFloat)
    // 依赖子视图
    case wrap
    
    public var value: CGFloat {
        switch self {
        case .fixed(let value): return value
        case .ratio(let ratio): return ratio
        case .wrap: return -1
        }
    }
    
    public var isWrap: Bool {
        if case .wrap = self {
            return true
        }
        return false
    }
    
    public var isFixed: Bool {
        if case .fixed(_) = self {
            return true
        }
        return false
    }
    
    public var isRatio: Bool {
        if case .ratio(_) = self {
            return true
        }
        return false
    }
}

public struct Size {
    
    public var width: SizeType
    public var height: SizeType
    
    public init(width: SizeType = .fixed(0), height: SizeType = .fixed(0)) {
        self.width = width
        self.height = height
    }
    
    public func isFixed() -> Bool {
        return width.isFixed && height.isFixed
    }
    
    public func isWrap() -> Bool {
        return width.isWrap && height.isWrap
    }
    
    public func getMain(parent direction: Direction) -> SizeType {
        if case .x = direction {
            return width
        }
        return height
    }
    
    public func getCross(parent direction: Direction) -> SizeType {
        if case .x = direction {
            return height
        }
        return width
    }
}
