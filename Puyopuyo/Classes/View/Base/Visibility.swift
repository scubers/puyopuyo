//
//  Visibility.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/27.
//

import Foundation

public enum Visibility: CaseIterable, Outputing, CustomStringConvertible {
    public typealias OutputType = Visibility

    case visible // calculate and visible
    case invisible // calculate and invisible
    case free // non calculate and visible
    case gone // non calculate and invisible

    public var description: String {
        switch self {
        case .visible:
            return "visible"
        case .invisible:
            return "invisible"
        case .free:
            return "free"
        case .gone:
            return "gone"
        }
    }
}
