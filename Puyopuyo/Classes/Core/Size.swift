//
//  Size.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import Foundation

public enum SizeType {
    case fixed(CGFloat)
    case ratio(CGFloat) // main cross 将有两种计算方式
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
    public var main: SizeType
    public var cross: SizeType
    
    public var center = Offset()
    
    public init(main: SizeType = .fixed(0), cross: SizeType = .fixed(0), center: Offset = Offset()) {
        self.main = main
        self.cross = cross
        self.center = center
    }
    
    public func isFixed() -> Bool {
        return main.isFixed && cross.isFixed
    }
}

public struct FixedSize {
    public var main: CGFloat = 0
    public var cross: CGFloat = 0
    
    public var center = Offset()
    
    public init(main: CGFloat = 0, cross: CGFloat = 0, center: Offset = Offset()) {
        self.main = main
        self.cross = cross
        self.center = center
    }
    
    public func getSize() -> Size {
        return Size(main: .fixed(main), cross: .fixed(cross), center: center)
    }
}

