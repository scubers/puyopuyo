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
//
//public protocol Sizable {
//    var sizeType: SizeType { get }
//}
//
//public struct WrapSize: Sizable {
//    public init() {
//
//    }
//    public var sizeType: SizeType {
//        return .wrap
//    }
//}
//
//public struct Ratio: Sizable {
//    var ratio: CGFloat = 0
//    public init(_ ratio: CGFloat) {
//        self.ratio = ratio
//    }
//    public var sizeType: SizeType {
//        return .ratio(ratio)
//    }
//}
//
//extension CGFloat: Sizable {
//    public var sizeType: SizeType {
//        return .fixed(self)
//    }
//}
//
//extension Int: Sizable {
//    public var sizeType: SizeType {
//        return .fixed(CGFloat(self))
//    }
//}
//
//extension Double: Sizable {
//    public var sizeType: SizeType {
//        return .fixed(CGFloat(self))
//    }
//}
//
//extension Float: Sizable {
//    public var sizeType: SizeType {
//        return .fixed(CGFloat(self))
//    }
//}

public struct Offset {
    public var main: CGFloat = 0
    public var cross: CGFloat = 0
    public init(main: CGFloat = 0, cross: CGFloat = 0) {
        self.main = main
        self.cross = cross
    }
}

public struct Size {
    
    public var width: SizeType
    public var height: SizeType
    
    public var center: Offset
    
    public init(width: SizeType = .fixed(0), height: SizeType = .fixed(0), center: Offset = Offset()) {
        self.width = width
        self.height = height
        self.center = center
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

public struct Unit {
    public var size: Size
    public var center: Offset
    public init(size: Size = Size(), center: Offset = Offset()) {
        self.size = size
        self.center = center
    }
}
