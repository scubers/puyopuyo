//
//  Enums.swift
//  Puyopuyo
//
//  Created by J on 2021/9/13.
//

import Foundation

public enum Direction: CaseIterable, Outputing {
    public typealias OutputType = Direction
    case x, y
}

public enum Format: CaseIterable, Outputing {
    public typealias OutputType = Format
    case leading
    case center
    case between
    case round
    case trailing
}

public struct Alignment: OptionSet, CustomStringConvertible, Outputing {
    public typealias OutputType = Alignment
    public var description: String {
        let all = [Alignment.top, .left, .bottom, .right, .horzCenter, .vertCenter]
        let contain = all.filter { self.contains($0) }
        return
            contain.map { x -> String in
                switch x {
                case .top: return "top"
                case .left: return "left"
                case .bottom: return "bottom"
                case .right: return "right"
                case .vertCenter: return "vertCenter"
                case .horzCenter: return "horzCenter"
                default: return ""
                }
            }.joined(separator: ",")
    }

    public init(rawValue: Int) {
        self.init(rawValue: rawValue, ratio: .zero)
    }

    public init(rawValue: Int, ratio: CGPoint) {
        self.rawValue = rawValue
        self.centerRatio = .init(x: max(-1, min(1, ratio.x)), y: max(-1, min(1, ratio.y)))
    }

    public typealias RawValue = Int
    public let rawValue: Int

    public static let none = Alignment(rawValue: 1)
    public static let top = Alignment(rawValue: 2)
    public static let bottom = Alignment(rawValue: 4)
    public static let left = Alignment(rawValue: 8)
    public static let right = Alignment(rawValue: 16)
    public static let horzCenter = Alignment(rawValue: 32)
    public static let vertCenter = Alignment(rawValue: 64)

    /// (-1, -1) < point < (1, 1)
    public let centerRatio: CGPoint
}

public extension Alignment {
    static let center = Alignment.vertCenter.union(.horzCenter)

    static func center(x: CGFloat = 0, y: CGFloat = 0) -> Alignment {
        .init(rawValue: center.rawValue, ratio: .init(x: x, y: y))
    }

    static func horzCenter(ratio: CGFloat = 0) -> Alignment {
        .init(rawValue: horzCenter.rawValue, ratio: .init(x: ratio, y: 0))
    }

    static func vertCenter(ratio: CGFloat = 0) -> Alignment {
        .init(rawValue: vertCenter.rawValue, ratio: .init(x: 0, y: ratio))
    }

    static func horzAlignments() -> [Alignment] {
        return [.left, .right, .horzCenter]
    }

    static func vertAlignments() -> [Alignment] {
        return [.top, .bottom, .vertCenter]
    }

    func hasHorzAlignment() -> Bool {
        return
            contains(.left)
                || contains(.right)
                || contains(.horzCenter)
    }

    func hasVertAlignment() -> Bool {
        return
            contains(.top)
                || contains(.bottom)
                || contains(.vertCenter)
    }

    func hasMainAligment(for direction: Direction) -> Bool {
        direction == .y ? hasVertAlignment() : hasHorzAlignment()
    }

    func hasCrossAligment(for direction: Direction) -> Bool {
        direction == .x ? hasVertAlignment() : hasHorzAlignment()
    }

    func isCenter(for direction: Direction) -> Bool {
        if case .x = direction {
            return contains(.vertCenter)
        }
        return contains(.horzCenter)
    }

    func isForward(for direction: Direction) -> Bool {
        if case .x = direction {
            return contains(.top)
        }
        return contains(.left)
    }

    func isBackward(for direction: Direction) -> Bool {
        if case .x = direction {
            return contains(.bottom)
        }
        return contains(.right)
    }
}
