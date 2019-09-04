//
//  Visibility.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/27.
//

import Foundation

public enum ControlState: CaseIterable {
    case controlled // 计算+可见
    case placeholder// 计算+不可见
    case free // 不计算+可见
    case gone // 不计算+不可见
}
