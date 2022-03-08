//
//  TimeProfiler.swift
//  Puyopuyo
//
//  Created by J on 2022/3/4.
//

import Foundation

func profileTime<T>(_ label: String? = nil, _ block: () -> T) -> T {
    let start = Date().timeIntervalSince1970
    let v = block()
    print("Profile \(label ?? "") : \(Date().timeIntervalSince1970 - start)s")
    return v
}
