//
//  Enums.swift
//  Puyopuyo
//
//  Created by J on 2021/9/13.
//

import Foundation

// MARK: - SemanticDirectionAttribute

public enum SemanticDirectionAttribute: Outputing {
    public typealias OutputType = SemanticDirectionAttribute
    case leftToRight
    case rightToLeft
}

extension SemanticDirectionAttribute {
    func getLeadingAlignment() -> Alignment {
        switch self {
        case .leftToRight: return .left
        case .rightToLeft: return .right
        }
    }

    func getTrailingAlignment() -> Alignment {
        switch self {
        case .leftToRight: return .right
        case .rightToLeft: return .left
        }
    }
}

// MARK: - Direction

public enum Direction: CaseIterable, Outputing {
    public typealias OutputType = Direction

    case horizontal, vertical

    public static var x: Direction { .horizontal }
    public static var y: Direction { .vertical }
}

// MARK: - Format

public enum Format: CaseIterable, Outputing {
    public typealias OutputType = Format
    case leading
    case center
    case between
    case round
    case trailing
}

// MARK: - Alignment

public struct Alignment: OptionSet, Equatable, CustomStringConvertible, Outputing {
    public typealias OutputType = Alignment
    public var description: String {
        let all = [Alignment.top, .left, .bottom, .right, .horzCenter, .vertCenter, .leading, .trailing]
        let contain = all.filter { self.contains($0) }
        return
            contain.map { x -> String in
                switch x {
                case .top: return "top"
                case .left: return "left"
                case .bottom: return "bottom"
                case .right: return "right"
                case .leading: return "leading"
                case .trailing: return "trailing"
                case .vertCenter: return "vc(\(centerRatio.y))"
                case .horzCenter: return "hc(\(centerRatio.x))"
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

    internal static let idle = Alignment([])
    public static let none = Alignment(rawValue: 1 << 0)
    public static let top = Alignment(rawValue: 1 << 1)
    public static let bottom = Alignment(rawValue: 1 << 2)
    public static let left = Alignment(rawValue: 1 << 3)
    public static let right = Alignment(rawValue: 1 << 4)
    public static let horzCenter = Alignment(rawValue: 1 << 5)
    public static let vertCenter = Alignment(rawValue: 1 << 6)
    public static let leading = Alignment(rawValue: 1 << 7)
    public static let trailing = Alignment(rawValue: 1 << 8)

    /// (-1, -1) < point < (1, 1)
    public let centerRatio: CGPoint

    public static func == (lhs: Alignment, rhs: Alignment) -> Bool {
        lhs.rawValue == rhs.rawValue && lhs.centerRatio == rhs.centerRatio
    }
}

public extension Alignment {
    static let center = Alignment([.vertCenter, horzCenter])

    static func center(_ xRatio: CGFloat = 0, _ yRatio: CGFloat = 0) -> Alignment {
        .init(rawValue: center.rawValue, ratio: .init(x: xRatio, y: yRatio))
    }

    static func horzCenter(_ ratio: CGFloat = 0) -> Alignment {
        .init(rawValue: horzCenter.rawValue, ratio: .init(x: ratio, y: 0))
    }

    static func vertCenter(_ ratio: CGFloat = 0) -> Alignment {
        .init(rawValue: vertCenter.rawValue, ratio: .init(x: 0, y: ratio))
    }

    static var horzAlignments: [Alignment] {
        [.left, .right, .horzCenter]
    }

    static var vertAlignments: [Alignment] {
        [.top, .bottom, .vertCenter]
    }

    var hasHorzAlignment: Bool {
        contains(.left)
            || contains(.right)
            || contains(.horzCenter)
    }

    var hasVertAlignment: Bool {
        contains(.top)
            || contains(.bottom)
            || contains(.vertCenter)
    }

    var hasSemanticAlignment: Bool {
        contains(.leading) || contains(.trailing)
    }

    func hasCrossAligment(for direction: Direction) -> Bool {
        switch direction {
        case .horizontal:
            return hasVertAlignment
        case .vertical:
            return hasHorzAlignment || hasSemanticAlignment
        }
    }

    func isCenter(for direction: Direction) -> Bool {
        if case .horizontal = direction {
            return contains(.vertCenter)
        }
        return contains(.horzCenter)
    }

    func isStart(for direction: Direction) -> Bool {
        if case .horizontal = direction {
            return contains(.top)
        }
        return contains(.left)
    }

    func isEnd(for direction: Direction) -> Bool {
        if case .horizontal = direction {
            return contains(.bottom)
        }
        return contains(.right)
    }
}
