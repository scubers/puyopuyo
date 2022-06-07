//
//  Model.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/5/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import HandyJSON


typealias CodableType = HandyJSON
typealias CodableEnumType = HandyJSONEnum

struct PuzzleInsets: CodableType {
    var top: CGFloat?
    var left: CGFloat?
    var bottom: CGFloat?
    var right: CGFloat?

    func getInsets() -> UIEdgeInsets {
        return .init(top: top ?? 0, left: left ?? 0, bottom: bottom ?? 0, right: right ?? 0)
    }

    static func from(_ insets: UIEdgeInsets) -> PuzzleInsets {
        return .init(top: insets.top, left: insets.left, bottom: insets.bottom, right: insets.right)
    }
}

class PuzzleSizeDesc: CodableType {
    required init() {}

    enum SizeType: String, CodableEnumType {
        case fixed
        case wrap
        case ratio
        case aspectRatio
    }

    var sizeType: SizeType = .wrap

    var fixedValue: CGFloat?
    var ratio: CGFloat?
    var add: CGFloat?
    var min: CGFloat?
    var max: CGFloat?
    var priority: CGFloat?
    var shrink: CGFloat?
    var grow: CGFloat?
    var aspectRatio: CGFloat?

    func getSizeDescription() -> SizeDescription {
        switch sizeType {
        case .fixed:
            return .fix(fixedValue ?? 0)
        case .ratio:
            return .ratio(ratio ?? 1)
        case .wrap:
            return .wrap(add: add ?? 0, min: min ?? 0, max: max ?? .greatestFiniteMagnitude, priority: priority ?? 0, shrink: shrink ?? 0, grow: grow ?? 0)
        case .aspectRatio:
            return .aspectRatio(aspectRatio ?? 0)
        }
    }

    static func from(_ sizeDescription: SizeDescription) -> PuzzleSizeDesc {
        let size = PuzzleSizeDesc()
        switch sizeDescription.sizeType {
        case .fixed:
            size.sizeType = .fixed
            size.fixedValue = sizeDescription.fixedValue
        case .ratio:
            size.sizeType = .ratio
            size.ratio = sizeDescription.ratio
        case .wrap:
            size.sizeType = .wrap
            size.add = sizeDescription.add
            size.min = sizeDescription.min
            size.max = sizeDescription.max
            size.priority = sizeDescription.priority
            size.shrink = sizeDescription.shrink
            size.grow = sizeDescription.grow
        case .aspectRatio:
            size.sizeType = .aspectRatio
            size.aspectRatio = sizeDescription.aspectRatio
        }
        return size
    }
}

class PuzzleAlignment: CodableType {
    required init() {}
    enum AlignmentType: String, CodableEnumType {
        case none, top, left, bottom, right, horzCenter, vertCenter
    }

    var alignment: [AlignmentType] = [.none]
    var centerRatio: CGPoint?

    func getAlignment() -> Alignment {
        var rawValue = 0
        if alignment.contains(.none) { rawValue = rawValue | Alignment.none.rawValue }
        if alignment.contains(.top) { rawValue = rawValue | Alignment.top.rawValue }
        if alignment.contains(.left) { rawValue = rawValue | Alignment.left.rawValue }
        if alignment.contains(.bottom) { rawValue = rawValue | Alignment.bottom.rawValue }
        if alignment.contains(.right) { rawValue = rawValue | Alignment.right.rawValue }
        if alignment.contains(.horzCenter) { rawValue = rawValue | Alignment.horzCenter.rawValue }
        if alignment.contains(.vertCenter) { rawValue = rawValue | Alignment.vertCenter.rawValue }
        return .init(rawValue: rawValue, ratio: centerRatio ?? .zero)
    }

    static func from(_ alignment: Alignment) -> PuzzleAlignment {
        let align = PuzzleAlignment()
        if alignment.centerRatio != .zero {
            align.centerRatio = alignment.centerRatio
        }
        align.alignment = []
        if alignment.contains(.top) { align.alignment.append(.top) }
        if alignment.contains(.left) { align.alignment.append(.left) }
        if alignment.contains(.bottom) { align.alignment.append(.bottom) }
        if alignment.contains(.right) { align.alignment.append(.right) }
        if alignment.contains(.horzCenter) { align.alignment.append(.horzCenter) }
        if alignment.contains(.vertCenter) { align.alignment.append(.vertCenter) }
        return align
    }
}

enum PuzzleDirection: String, CodableEnumType {
    case horizontal, vertical

    func getDirection() -> Direction {
        switch self {
        case .horizontal:
            return .horizontal
        case .vertical:
            return .vertical
        }
    }

    static func from(_ direction: Direction) -> PuzzleDirection {
        switch direction {
        case .horizontal:
            return .horizontal
        case .vertical:
            return .vertical
        }
    }
}

enum PuzzleFormat: String, CodableEnumType {
    case leading, center, between, round, trailing

    func getFormat() -> Format {
        switch self {
        case .leading:
            return .leading
        case .center:
            return .center
        case .between:
            return .between
        case .round:
            return .round
        case .trailing:
            return .trailing
        }
    }

    static func from(_ format: Format) -> PuzzleFormat {
        switch format {
        case .leading:
            return .leading
        case .center:
            return .center
        case .between:
            return .between
        case .round:
            return .round
        case .trailing:
            return .trailing
        }
    }
}

enum PuzzleVisibility: String, CodableEnumType {
    case visible, invisible, gone, free

    func getVisibility() -> Visibility {
        switch self {
        case .visible:
            return .visible
        case .invisible:
            return .invisible
        case .gone:
            return .gone
        case .free:
            return .free
        }
    }

    static func from(_ visibility: Visibility) -> PuzzleVisibility {
        switch visibility {
        case .visible:
            return .visible
        case .invisible:
            return .invisible
        case .gone:
            return .gone
        case .free:
            return .free
        }
    }
}

// code gen

extension Alignment {
    func genCode() -> String {
        var values = [String]()
        if contains(.top) { values.append(".top") }
        if contains(.left) { values.append(".left") }
        if contains(.bottom) { values.append(".bottom") }
        if contains(.right) { values.append(".right") }
        if contains(.horzCenter) { values.append(".horzCenter") }
        if contains(.vertCenter) { values.append(".vertCenter") }
        return "[\(values.joined(separator: ", "))]"
    }
}

extension SizeDescription {
    func genCode() -> String {
        var param: String
        switch sizeType {
        case .fixed:
            param = ".fix(\(fixedValue))"
        case .ratio:
            param = ".ratio(\(ratio))"
        case .wrap:
            let defaultValue = SizeDescription.wrap
            var values = [String]()
            if add != defaultValue.add { values.append("add: \(add)") }
            if min != defaultValue.min { values.append("min: \(min)") }
            if max != defaultValue.max { values.append("max: \(max)") }
            if priority != defaultValue.priority { values.append("priority: \(priority)") }
            if shrink != defaultValue.shrink { values.append("shrink: \(shrink)") }
            if grow != defaultValue.grow { values.append("grow: \(grow)") }
            if values.isEmpty {
                param = ".wrap"
            } else {
                param = ".wrap(\(values.joined(separator: ", ")))"
            }
        case .aspectRatio:
            param = ".aspectRatio(\(aspectRatio))"
        }

        return param
    }
}

extension Format {
    func genCode() -> String {
        var param: String
        switch self {
        case .leading:
            param = ".leading"
        case .center:
            param = ".center"
        case .between:
            param = ".between"
        case .round:
            param = ".round"
        case .trailing:
            param = ".trailing"
        }
        return param
    }
}

extension Direction {
    func genCode() -> String {
        var param: String
        switch self {
        case .horizontal: param = ".horizontal"
        case .vertical: param = ".vertical"
        }
        return param
    }
}
