//
//  SimpleOutput.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/8.
//

import Foundation

public typealias SimpleOutput = Outputs
public struct Outputs<Value>: Outputing {
    public typealias OutputType = Value

    private var action: (Inputs<Value>) -> Disposer

    public init(_ block: @escaping (Inputs<Value>) -> Disposer) {
        action = block
    }

    public init<T: Outputing>(from: T) where T.OutputType == Value {
        action = { (input: Inputs<Value>) -> Disposer in
            from.outputing { x in
                input.input(value: x)
            }
        }
    }

    public func outputing(_ block: @escaping (Value) -> Void) -> Disposer {
        let input = Inputs<Value> { x in
            block(x)
        }
        return action(input)
    }

    public static func merge<T: Outputing>(_ outputs: [T]) -> Outputs<Value> where T.OutputType == Value {
        return Outputs<Value> { i -> Disposer in
            let disposables = outputs.map { o -> Disposer in
                o.outputing { v in
                    i.input(value: v)
                }
            }
            return Disposables.create {
                disposables.forEach { $0.dispose() }
            }
        }
    }

    public static func only(_ value: Value) -> Outputs<Value> {
        .init {
            $0.input(value: value)
            return Disposables.create()
        }
    }
}

public extension Outputing {
    func asOutput() -> Outputs<OutputType> {
        Outputs { i -> Disposer in
            self.outputing { v in
                i.input(value: v)
            }
        }
    }

    func some() -> Outputs<OutputType?> {
        asOutput().map { $0 }
    }
}

public extension Outputs {
    func bind<T>(_ action: @escaping (OutputType, Inputs<T>) -> Void) -> Outputs<T> {
        Outputs<T>({ i -> Disposer in
            self.outputing { v in
                action(v, i)
            }
        })
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

    func scheduleOn(_ queue: OperationQueue) -> Outputs<OutputType> {
        bind { v, i in
            if OperationQueue.current == queue {
                i.input(value: v)
            } else {
                queue.addOperation {
                    i.input(value: v)
                }
            }
        }
    }

    func scheduleOnMain() -> Outputs<OutputType> {
        scheduleOn(OperationQueue.main)
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
