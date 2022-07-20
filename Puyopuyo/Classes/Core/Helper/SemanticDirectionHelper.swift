//
//  RTLHelper.swift
//  Puyopuyo
//
//  Created by J on 2022/7/20.
//

import Foundation

struct SemanticDirectionHelper {
    let semanticDirection: SemanticDirection

    func transform(format: Format, formattable: Bool, in direction: Direction) -> Format {
        guard semanticDirection == .rightToLeft, formattable, direction == .horizontal else {
            return format
        }
        switch format {
        case .leading: return .trailing
        case .trailing: return .leading
        default: return format
        }
    }

    func transform(reverse: Bool, in direction: Direction) -> Bool {
        guard semanticDirection == .rightToLeft else {
            return reverse
        }
        if direction == .horizontal {
            return !reverse
        }
        return reverse
    }

    func transform(alignment: Alignment) -> Alignment {
        var new = alignment
        if !new.contains(.left), !new.contains(.right) {
            // 处理左右
            if new.contains(.leading) || new.contains(.trailing) {
                if new.contains(.leading) {
                    new = new.union(semanticDirection.getLeadingAlignment())
                    new.remove(.leading)
                } else {
                    new = new.union(semanticDirection.getTrailingAlignment())
                    new.remove(.trailing)
                }
            }
        }
        var centerRatio = new.centerRatio
        if new.contains(.horzCenter), semanticDirection == .rightToLeft {
            centerRatio.x = -centerRatio.x
        }
        return Alignment(rawValue: new.rawValue, ratio: centerRatio)
    }
}
