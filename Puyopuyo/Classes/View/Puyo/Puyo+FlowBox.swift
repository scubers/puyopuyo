//
//  Puyo+FlowBox.swift
//  Puyopuyo
//
//  Created by J on 2021/9/11.
//

import Foundation

// MARK: - FlowBox

public extension Puyo where T: RegulatorSpecifier & AutoDisposable, T.RegulatorType: FlowRegulator {
    @discardableResult
    func arrangeCount<O: Outputing>(_ count: O) -> Self where O.OutputType == Int {
        set(\T.regulator.arrange, count)
    }

    @discardableResult
    func itemSpace<O: Outputing>(_ space: O) -> Self where O.OutputType: CGFloatable {
        set(\T.regulator.itemSpace, space.mapCGFloat())
    }

    @discardableResult
    func runSpace<O: Outputing>(_ space: O) -> Self where O.OutputType: CGFloatable {
        set(\T.regulator.runSpace, space.mapCGFloat())
        return self
    }

    @discardableResult
    func runFormat(_ format: Format) -> Self {
        set(\T.regulator.runFormat, format)
    }

    @discardableResult
    func runFormat<O: Outputing>(_ formation: O) -> Self where O.OutputType == Format {
        set(\T.regulator.runFormat, formation)
    }

    @discardableResult
    func runRowSize(each: @escaping (Int) -> SizeDescription) -> Self {
        set(\T.regulator.runRowSize, each)
    }

    @discardableResult
    func runRowSize<O: Outputing>(_ size: O) -> Self where O.OutputType: SizeDescriptible {
        set(\T.regulator.runRowSize, size.asOutput().map(\.sizeDescription).map { s in { _ in s }})
    }

    @discardableResult
    func runRowSize(_ size: SizeDescription) -> Self {
        runRowSize(each: { _ in size })
    }
}
