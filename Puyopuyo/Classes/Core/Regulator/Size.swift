//
//  Size.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import Foundation

// MARK: - SizeDescriptible

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

// MARK: - SizeDescription

///
/// Measure a size in one dimension
public struct SizeDescription: SizeDescriptible, CustomStringConvertible, Outputing, Equatable {
    init(sizeType: SizeDescription.SizeType, fixedValue: CGFloat, ratio: CGFloat, aspectRatio: CGFloat, add: CGFloat, min: CGFloat, max: CGFloat, priority: CGFloat, shrink: CGFloat, grow: CGFloat) {
        if grow > 0 {
            assert(max == .greatestFiniteMagnitude, "Grow size should not have a max value")
        }

        self.sizeType = sizeType
        self.fixedValue = fixedValue
        self.ratio = ratio
        self.add = add
        self.min = min
        self.max = max
        self.priority = priority
        self.shrink = shrink
        self.grow = grow
        self.aspectRatio = aspectRatio
    }

    public typealias OutputType = SizeDescription

    public var sizeDescription: SizeDescription {
        return self
    }

    public enum SizeType {
        /// Fixed size
        case fixed
        /// Depende on residual size
        case ratio
        /// Depende on content
        case wrap
        /// Depende on the other dimension size
        case aspectRatio
    }

    public let sizeType: SizeType

    public let fixedValue: CGFloat

    public let ratio: CGFloat
    public let add: CGFloat
    public let min: CGFloat
    public let max: CGFloat
    public let priority: CGFloat
    public let shrink: CGFloat
    public let grow: CGFloat
    public let aspectRatio: CGFloat

    public static func fix(_ value: CGFloat) -> SizeDescription {
        SizeDescription(sizeType: .fixed, fixedValue: value, ratio: 0, aspectRatio: 0, add: 0, min: 0, max: .greatestFiniteMagnitude, priority: 0, shrink: 0, grow: 0)
    }

    public static func ratio(_ value: CGFloat) -> SizeDescription {
        SizeDescription(sizeType: .ratio, fixedValue: 0, ratio: value, aspectRatio: 0, add: 0, min: 0, max: .greatestFiniteMagnitude, priority: 0, shrink: 0, grow: 0)
    }

    public static func wrap(add: CGFloat = 0, min: CGFloat = 0, max: CGFloat = .greatestFiniteMagnitude, priority: CGFloat = 0, shrink: CGFloat = 0, grow: CGFloat = 0) -> SizeDescription {
        SizeDescription(sizeType: .wrap, fixedValue: 0, ratio: 0, aspectRatio: 0, add: add, min: min, max: grow > 0 ? .greatestFiniteMagnitude : max, priority: priority, shrink: shrink, grow: grow)
    }

    public static var wrap: SizeDescription {
        .wrap()
    }

    public static var fill: SizeDescription {
        .ratio(1)
    }

    public static func aspectRatio(_ value: CGFloat) -> SizeDescription {
        SizeDescription(sizeType: .aspectRatio, fixedValue: value, ratio: 0, aspectRatio: value, add: 0, min: 0, max: .greatestFiniteMagnitude, priority: 0, shrink: 0, grow: 0)
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
        } else if isAspectRatio {
            return "aspect(\(aspectRatio))"
        } else {
            return "fix(\(fixedValue))"
        }
    }
}

extension SizeDescription {
    var isWrap: Bool {
        sizeType == .wrap
    }

    var isFixed: Bool {
        sizeType == .fixed
    }

    var isRatio: Bool {
        sizeType == .ratio
    }

    var isFlex: Bool {
        isWrap && (grow > 0 || shrink > 0)
    }

    var isAspectRatio: Bool {
        sizeType == .aspectRatio
    }

    func getWrapSize(by wrappedValue: CGFloat) -> CGFloat {
        Swift.min(Swift.max(wrappedValue + add, min), max)
    }
}

// MARK: - Size

public struct Size: Equatable, Outputing {
    public typealias OutputType = Size
    public var width: SizeDescription
    public var height: SizeDescription

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.width == rhs.width && lhs.height == rhs.height
    }

    public init(width: SizeDescription = .fix(0), height: SizeDescription = .fix(0)) {
        self.width = width
        self.height = height
    }

    public static func fixed(_ value: CGFloat = 0) -> Size {
        Size(width: .fix(value), height: .fix(value))
    }

    public static func flex<O: Outputing>(main: SizeDescription, cross: SizeDescription, axis: O) -> Outputs<Size> where O.OutputType == Direction {
        axis.asOutput().distinct().map {
            switch $0 {
            case .horizontal: return Size(width: main, height: cross)
            case .vertical: return Size(width: cross, height: main)
            }
        }
    }

    public var isCalculable: Bool {
        !(width.sizeType == .aspectRatio && height.sizeType == .aspectRatio)
    }

    /// width / height
    public var aspectRatio: CGFloat? {
        if width.isAspectRatio { return width.aspectRatio }
        if height.isAspectRatio { return height.aspectRatio }
        return nil
    }
}

extension Size {
    var isFixed: Bool {
        width.isFixed && height.isFixed
    }

    var isRatio: Bool {
        width.isRatio && height.isRatio
    }

    var isWrap: Bool {
        width.isWrap && height.isWrap
    }

    var bothNotWrap: Bool {
        !maybeWrap
    }

    var maybeWrap: Bool {
        width.isWrap || height.isWrap
    }

    var maybeRatio: Bool {
        width.isRatio || height.isRatio
    }

    var maybeFixed: Bool {
        width.isFixed || height.isFixed
    }

    func getMain(direction: Direction) -> SizeDescription {
        if case .x = direction {
            return width
        }
        return height
    }

    func getCross(direction: Direction) -> SizeDescription {
        if case .x = direction {
            return height
        }
        return width
    }

    func getMainCrossRatio(direction: Direction) -> CGFloat? {
        var value: CGFloat?
        if width.isAspectRatio {
            value = width.aspectRatio
        } else if height.isAspectRatio {
            value = height.aspectRatio
        }
        if let value = value {
            switch direction {
            case .horizontal:
                return value
            case .vertical:
                return 1 / value
            }
        }
        return nil
    }
}
