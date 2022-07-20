//
//  RTLHelper.swift
//  Puyopuyo
//
//  Created by J on 2022/7/20.
//

import Foundation

struct SemanticDirectionHelper {
    let attribute: SemanticDirectionAttribute

    func transform(format: Format, formattable: Bool, in direction: Direction) -> Format {
        guard attribute == .rightToLeft, formattable, direction == .horizontal else {
            return format
        }
        switch format {
        case .leading: return .trailing
        case .trailing: return .leading
        default: return format
        }
    }

    func transform(reverse: Bool, in direction: Direction) -> Bool {
        guard attribute == .rightToLeft else {
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
                    new = new.union(attribute.getLeadingAlignment())
                    new.remove(.leading)
                } else {
                    new = new.union(attribute.getTrailingAlignment())
                    new.remove(.trailing)
                }
            }
        }
        var centerRatio = new.centerRatio
        if new.contains(.horzCenter), attribute == .rightToLeft {
            centerRatio.x = -centerRatio.x
        }
        return Alignment(rawValue: new.rawValue, ratio: centerRatio)
    }
}
