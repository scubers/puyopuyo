//
//  Visibility.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/27.
//

import Foundation

public enum Visibility: CaseIterable, Outputing {
    public typealias OutputType = Visibility

    case visible // 计算+可见
    case invisible // 计算+不可见
    case free // 不计算+可见
    case gone // 不计算+不可见
}
