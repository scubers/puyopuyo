//
//  Puyo+FlatBox.swift
//  Puyopuyo
//
//  Created by J on 2021/9/11.
//

import Foundation

// MARK: - FlatBox

public extension Puyo where T: Boxable & UIView, T.RegulatorType: FlatRegulator {
    @discardableResult
    func space<O: Outputing>(_ space: O) -> Self where O.OutputType: CGFloatable {
        bind(keyPath: \T.regulator.space, space.mapCGFloat())
    }

    @discardableResult
    func format(_ formation: Format) -> Self {
        bind(keyPath: \T.regulator.format, formation)
    }

    @discardableResult
    func format<O: Outputing>(_ formation: O) -> Self where O.OutputType == Format {
        bind(keyPath: \T.regulator.format, formation)
    }

    @discardableResult
    func direction(_ direction: Direction) -> Self {
        bind(keyPath: \T.regulator.direction, direction)
    }

    @discardableResult
    func direction<O: Outputing>(_ direction: O) -> Self where O.OutputType == Direction {
        bind(keyPath: \T.regulator.direction, direction)
    }

    @discardableResult
    func reverse<O: Outputing>(_ reverse: O) -> Self where O.OutputType == Bool {
        bind(keyPath: \T.regulator.reverse, reverse)
    }
}
