//
//  Size.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import Foundation

public protocol SizeDescriptible {
    var sizeDescription: SizeDescription { get }
}

extension CGFloat: SizeDescriptible { public var sizeDescription: SizeDescription { return .fix(self) } }
extension Double: SizeDescriptible { public var sizeDescription: SizeDescription { return .fix(CGFloat(self)) } }
extension Float: SizeDescriptible { public var sizeDescription: SizeDescription { return .fix(CGFloat(self)) } }
extension Int: SizeDescriptible { public var sizeDescription: SizeDescription { return .fix(CGFloat(self)) } }
extension UInt: SizeDescriptible { public var sizeDescription: SizeDescription { return .fix(CGFloat(self)) } }
extension Int32: SizeDescriptible { public var sizeDescription: SizeDescription { return .fix(CGFloat(self)) } }
extension UInt32: SizeDescriptible { public var sizeDescription: SizeDescription { return .fix(CGFloat(self)) } }
extension Int64: SizeDescriptible { public var sizeDescription: SizeDescription { return .fix(CGFloat(self)) } }
extension UInt64: SizeDescriptible { public var sizeDescription: SizeDescription { return .fix(CGFloat(self)) } }

/// 描述一个测量长度
public struct SizeDescription: SizeDescriptible, CustomStringConvertible, Outputing, Equatable {
    public typealias OutputType = SizeDescription

    public var sizeDescription: SizeDescription {
        return self
    }

    public enum SizeType {
        // 固有尺寸
        case fixed
        // 依赖父视图
        case ratio
        // 依赖子视图
        case wrap
    }

    public let sizeType: SizeType

    public let fixedValue: CGFloat

    public let ratio: CGFloat
    public let add: CGFloat
    public let min: CGFloat
    public let max: CGFloat
    public let priority: CGFloat
    public let shrink: CGFloat

    public static func fix(_ value: CGFloat) -> SizeDescription {
        return SizeDescription(sizeType: .fixed, fixedValue: value, ratio: 0, add: 0, min: 0, max: .greatestFiniteMagnitude, priority: 0, shrink: 0)
    }

    public static func ratio(_ value: CGFloat) -> SizeDescription {
        return SizeDescription(sizeType: .ratio, fixedValue: 0, ratio: value, add: 0, min: 0, max: .greatestFiniteMagnitude, priority: 0, shrink: 0)
    }

    public static func wrap(add: CGFloat = 0, min: CGFloat = 0, max: CGFloat = .greatestFiniteMagnitude, priority: CGFloat = 0, shrink: CGFloat = 0) -> SizeDescription {
        return SizeDescription(sizeType: .wrap, fixedValue: 0, ratio: 0, add: add, min: min, max: max, priority: priority, shrink: shrink)
    }

    public static var wrap: SizeDescription {
        return .wrap()
    }

    public static var fill: SizeDescription {
        return .ratio(1)
    }

    public var isWrap: Bool {
        return sizeType == .wrap
    }

    public var isFixed: Bool {
        return sizeType == .fixed
    }

    public var isRatio: Bool {
        return sizeType == .ratio
    }

    public func getWrapSize(by wrappedValue: CGFloat) -> CGFloat {
        return Swift.min(Swift.max(wrappedValue + add, min), max)
    }

    public var description: String {
        if isRatio {
            return "ratio(\(ratio))"
        } else if isWrap {
            var text = [String]()
            if add != 0 { text.append("add:\(add)") }
            if min != 0 { text.append("min:\(min)") }
            if max != .greatestFiniteMagnitude { text.append("max:\(max)") }
            if priority != 0 { text.append("priority:\(priority)") }
            if shrink != 0 { text.append("shrink:\(shrink)") }
            return "wrap(\(text.joined(separator: ", ")))"
        } else {
            return "fix(\(fixedValue))"
        }
    }
}

/// 描述一个测量宽高
public struct Size: Equatable, Outputing {
    public typealias OutputType = Size
    public var width: SizeDescription
    public var height: SizeDescription

    /// width / height
    public var aspectRatio: CGFloat?

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.width == rhs.width && lhs.height == rhs.height
    }

    public init(width: SizeDescription = .fix(0), height: SizeDescription = .fix(0), aspectRatio: CGFloat? = nil) {
        self.width = width
        self.height = height
        self.aspectRatio = aspectRatio
    }

    public static func fixed(_ value: CGFloat = 0) -> Size {
        Size(width: .fix(value), height: .fix(value))
    }

    public func isFixed() -> Bool {
        return width.isFixed && height.isFixed
    }

    public func isRatio() -> Bool {
        return width.isRatio && height.isRatio
    }

    public func isWrap() -> Bool {
        return width.isWrap && height.isWrap
    }

    public func getMain(direction: Direction) -> SizeDescription {
        if case .x = direction {
            return width
        }
        return height
    }

    public func getCross(direction: Direction) -> SizeDescription {
        if case .x = direction {
            return height
        }
        return width
    }

    public func bothNotWrap() -> Bool {
        return !maybeWrap()
    }

    public func maybeWrap() -> Bool {
        return width.isWrap || height.isWrap
    }

    public func maybeRatio() -> Bool {
        return width.isRatio || height.isRatio
    }

    public func maybeFixed() -> Bool {
        return width.isFixed || height.isFixed
    }
}
