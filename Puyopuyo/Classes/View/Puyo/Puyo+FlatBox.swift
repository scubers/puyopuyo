//
//  Puyo+LinearBox.swift
//  Puyopuyo
//
//  Created by J on 2021/9/11.
//

import Foundation

// MARK: - LinearBox

public extension Puyo where T: RegulatorSpecifier & AutoDisposable, T.RegulatorType: LinearRegulator {
    /// Space between subviews
    @discardableResult
    func space<O: Outputing>(_ space: O) -> Self where O.OutputType: CGFloatable {
        bind(\T.regulator.space, space.mapCGFloat())
    }

    /// Main axis formation
    @discardableResult
    func format(_ formation: Format) -> Self {
        bind(\T.regulator.format, formation)
    }

    @discardableResult
    func format<O: Outputing>(_ formation: O) -> Self where O.OutputType == Format {
        bind(\T.regulator.format, formation)
    }

    /// Layout children's direction
    @discardableResult
    func direction(_ direction: Direction) -> Self {
        bind(\T.regulator.direction, direction)
    }

    @discardableResult
    func direction<O: Outputing>(_ direction: O) -> Self where O.OutputType == Direction {
        bind(\T.regulator.direction, direction)
    }

    /// Layout children's position in the reverse order of adding order
    @discardableResult
    func reverse<O: Outputing>(_ reverse: O) -> Self where O.OutputType == Bool {
        bind(\T.regulator.reverse, reverse)
    }
}
