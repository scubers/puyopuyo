//
//  Visibility.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/27.
//

import Foundation

public enum Visibility: CaseIterable, Outputing {
    public typealias OutputType = Visibility

    case visible // calculate and visible
    case invisible // calculate and invisible
    case free // non calculate and visible
    case gone // non calculate and invisible
}
