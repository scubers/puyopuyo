//
//  OutputModifier.swift
//  Puyopuyo
//
//  Created by J on 2021/8/30.
//

import Foundation

public protocol OutputingModifier {}

public extension OutputingModifier where Self: Outputing {
    func bind<T>(_ action: @escaping (OutputType, Inputs<T>) -> Void) -> Outputs<T> {
        Outputs<T>({ i -> Disposer in
            self.outputing { v in
                action(v, i)
            }
        })
    }

    func some() -> Outputs<OutputType?> {
        asOutput().map { $0 }
    }

    func map<R>(_ block: @escaping (OutputType) -> R) -> Outputs<R> {
        bind { $1.input(value: block($0)) }
    }

    func map<R>(_ keyPath: KeyPath<OutputType, R>) -> Outputs<R> {
        bind { $1.input(value: $0[keyPath: keyPath]) }
    }

    func filter(_ filter: @escaping (OutputType) -> Bool) -> Outputs<OutputType> {
        bind { v, i in
            if filter(v) { i.input(value: v) }
        }
    }

    func ignore(_ condition: @escaping (OutputType, OutputType) -> Bool) -> Outputs<OutputType> {
        var last: OutputType!
        return bind { v, i in
            guard last != nil else {
                last = v
                i.input(value: v)
                return
            }
            let ignore = condition(last, v)
            last = v
            if !ignore {
                i.input(value: v)
            }
        }
    }

    func take(_ count: Int) -> Outputs<OutputType> {
        var times: Int = 0
        return bind { v, i in
            guard times <= count else { return }
            times += 1
            i.input(value: v)
        }
    }

    func skip(_ count: Int) -> Outputs<OutputType> {
        var times = 0
        return bind { v, i in
            guard times > count else {
                times += 1
                return
            }
            i.input(value: v)
        }
    }

    func then<R>(_ then: @escaping (OutputType) -> Outputs<R>) -> Outputs<R> {
        bind { o, i in
            _ = then(o).outputing { v in
                i.input(value: v)
            }
        }
    }
}

public extension Outputs where OutputType: OptionalableValueType {
    func map<R>(_ keyPath: KeyPath<OutputType.Wrap, R>, _ default: R) -> Outputs<R?> {
        bind {
            if let v = $0.optionalValue {
                $1.input(value: v[keyPath: keyPath])
            } else {
                $1.input(value: `default`)
            }
        }
    }
}

public extension Outputs where OutputType: OptionalableValueType {
    func unwrap(or: OutputType.Wrap) -> Outputs<OutputType.Wrap> {
        bind { v, i in
            if let v = v.optionalValue {
                i.input(value: v)
            } else {
                i.input(value: or)
            }
        }
    }
}

public extension Outputs where OutputType: Equatable {
    func distinct() -> Outputs<OutputType> {
        ignore { $0 == $1 }
    }
}
