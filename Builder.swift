//
//  Builder.swift
//  Puyopuyo
//
//  Created by J on 2022/4/27.
//

import Foundation

public typealias BoxBuilder<T> = (T) -> Void
public typealias BoxGenerator<T> = () -> T
