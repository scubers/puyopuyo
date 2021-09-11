//
//  Puyo+FlowBox.swift
//  Puyopuyo
//
//  Created by J on 2021/9/11.
//

import Foundation

// MARK: - FlowBox

public extension Puyo where T: Boxable & UIView, T.RegulatorType: FlowRegulator {
    @discardableResult
    func arrangeCount<O: Outputing>(_ count: O) -> Self where O.OutputType == Int {
        bind(keyPath: \T.regulator.arrange, count)
    }

    @discardableResult
    func itemSpace<O: Outputing>(_ space: O) -> Self where O.OutputType: CGFloatable {
        bind(keyPath: \T.regulator.itemSpace, space.mapCGFloat())
    }

    @discardableResult
    func runSpace<O: Outputing>(_ space: O) -> Self where O.OutputType: CGFloatable {
        bind(keyPath: \T.regulator.runSpace, space.mapCGFloat())
        return self
    }

    @discardableResult
    func runFormat(_ format: Format) -> Self {
        bind(keyPath: \T.regulator.runFormat, format)
    }

    @discardableResult
    func runFormat<O: Outputing>(_ formation: O) -> Self where O.OutputType == Format {
        bind(keyPath: \T.regulator.runFormat, formation)
    }

    @discardableResult
    func runingRowSize(each: @escaping (Int) -> SizeDescription) -> Self {
        view.regulator.runingRowSize = each
        return self
    }

    @discardableResult
    func runingRowSize<O: Outputing>(_ size: O) -> Self where O.OutputType: SizeDescriptible {
        size.asOutput().map { $0.sizeDescription }.distinct().safeBind(to: view) { v, a in
            v.regulator.runingRowSize = { _ in a }
        }
        return self
    }

    @discardableResult
    func runingRowSize(_ size: SizeDescription) -> Self {
        runingRowSize(each: { _ in size })
    }
}
