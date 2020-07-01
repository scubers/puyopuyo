//
//  SimpleOutput.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/8.
//

import Foundation

public struct SimpleOutput<Value>: Outputing {
    public typealias OutputType = Value

    private var action: (SimpleInput<Value>) -> Unbinder

    public init(_ block: @escaping (SimpleInput<Value>) -> Unbinder) {
        action = block
    }

    public init<T: Outputing>(from: T) where T.OutputType == Value {
        action = { (input: SimpleInput<Value>) -> Unbinder in
            from.outputing { x in
                input.input(value: x)
            }
        }
    }

    public func outputing(_ block: @escaping (Value) -> Void) -> Unbinder {
        let input = SimpleInput<Value> { x in
            block(x)
        }
        return action(input)
    }

    public static func merge<T: Outputing>(_ outputs: [T]) -> SimpleOutput<Value> where T.OutputType == Value {
        return SimpleOutput<Value> { (i) -> Unbinder in
            let unbinders = outputs.map { (o) -> Unbinder in
                o.outputing { v in
                    i.input(value: v)
                }
            }
            return Unbinders.create {
                unbinders.forEach { $0.py_unbind() }
            }
        }
    }

    public static func just(_ value: Value) -> SimpleOutput<Value> {
        .init {
            $0.input(value: value)
            return Unbinders.create()
        }
    }
}

public extension Outputing {
    func asOutput() -> SimpleOutput<OutputType> {
        return SimpleOutput { (i) -> Unbinder in
            self.outputing { v in
                i.input(value: v)
            }
        }
    }
}

// extension Yo where Base: Outputing {
public extension SimpleOutput {
    func some() -> SimpleOutput<OutputType?> {
        return map { $0 }
    }

    func bind<T>(_ action: @escaping (OutputType, SimpleInput<T>) -> Void) -> SimpleOutput<T> {
        return SimpleOutput<T>({ (i) -> Unbinder in
            self.outputing { v in
                action(v, i)
            }
        })
    }

    func map<R>(_ block: @escaping (OutputType) -> R) -> SimpleOutput<R> {
        return bind { $1.input(value: block($0)) }
    }

    func map<R>(_ keyPath: KeyPath<OutputType, R>) -> SimpleOutput<R> {
        bind { $1.input(value: $0[keyPath: keyPath]) }
    }

    func filter(_ filter: @escaping (OutputType) -> Bool) -> SimpleOutput<OutputType> {
        return bind { v, i in
            if filter(v) { i.input(value: v) }
        }
    }

    func ignore(_ condition: @escaping (OutputType, OutputType) -> Bool) -> SimpleOutput<OutputType> {
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

    func distinct<R>(by keyPath: KeyPath<OutputType, R>) -> SimpleOutput<OutputType> where R: Equatable {
        ignore {
            $0[keyPath: keyPath] == $1[keyPath: keyPath]
        }
    }

    func distinctMap<R>(_ kp: KeyPath<OutputType, R>) -> SimpleOutput<R> where R: Equatable {
        distinct(by: kp).map(kp)
    }

    func take(_ count: Int) -> SimpleOutput<OutputType> {
        var times: Int = 0
        return bind { v, i in
            guard times <= count else { return }
            times += 1
            i.input(value: v)
        }
    }

    func skip(_ count: Int) -> SimpleOutput<OutputType> {
        var times = 0
        return bind { v, i in
            guard times > count else {
                times += 1
                return
            }
            i.input(value: v)
        }
    }

    func scheduleOn(_ queue: OperationQueue) -> SimpleOutput<OutputType> {
        return bind { v, i in
            if OperationQueue.current == queue {
                i.input(value: v)
            } else {
                queue.addOperation {
                    i.input(value: v)
                }
            }
        }
    }

    func scheduleOnMain() -> SimpleOutput<OutputType> {
        return scheduleOn(OperationQueue.main)
    }
}

public extension SimpleOutput where OutputType: PuyoOptionalType {
    func map<R>(_ keyPath: KeyPath<OutputType.PuyoWrappedType, R>, _ default: R) -> SimpleOutput<R?> {
        bind {
            if let v = $0.puyoWrapValue {
                $1.input(value: v[keyPath: keyPath])
            } else {
                $1.input(value: `default`)
            }
        }
    }
}

public extension Outputing {
    func some() -> SimpleOutput<OutputType?> {
        return mapTo { $0 }
    }

    func _bind<T>(action: @escaping (OutputType, SimpleInput<T>) -> Void) -> SimpleOutput<T> {
        return SimpleOutput<T>({ (i) -> Unbinder in
            self.outputing { v in
                action(v, i)
            }
        })
    }

    func mapTo<R>(_ block: @escaping (OutputType) -> R) -> SimpleOutput<R> {
        return _bind { $1.input(value: block($0)) }
    }

    func mapTo<R>(_ keyPath: KeyPath<OutputType, R>) -> SimpleOutput<R> {
        _bind { $1.input(value: $0[keyPath: keyPath]) }
    }

    func filterBy(_ filter: @escaping (OutputType) -> Bool) -> SimpleOutput<OutputType> {
        return _bind { v, i in
            if filter(v) { i.input(value: v) }
        }
    }

    func ignoreBy(_ condition: @escaping (OutputType, OutputType) -> Bool) -> SimpleOutput<OutputType> {
        var last: OutputType!
        return _bind { v, i in
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

    func distinct<R>(by keyPath: KeyPath<OutputType, R>) -> SimpleOutput<OutputType> where R: Equatable {
        ignoreBy {
            $0[keyPath: keyPath] == $1[keyPath: keyPath]
        }
    }

    func distinctMap<R>(_ kp: KeyPath<OutputType, R>) -> SimpleOutput<R> where R: Equatable {
        distinct(by: kp).map(kp)
    }

    func takeCount(_ count: Int) -> SimpleOutput<OutputType> {
        var times: Int = 0
        return _bind { v, i in
            guard times <= count else { return }
            times += 1
            i.input(value: v)
        }
    }

    func skipCount(_ count: Int) -> SimpleOutput<OutputType> {
        var times = 0
        return _bind { v, i in
            guard times > count else {
                times += 1
                return
            }
            i.input(value: v)
        }
    }
}

extension Outputing where OutputType: PuyoOptionalType {
    public func unwrap(or: OutputType.PuyoWrappedType) -> SimpleOutput<OutputType.PuyoWrappedType> {
        return _bind { v, i in
            if let v = v.puyoWrapValue {
                i.input(value: v)
            } else {
                i.input(value: or)
            }
        }
    }
}

extension Outputing where OutputType: Equatable {
    public func distinct() -> SimpleOutput<OutputType> {
        return ignoreBy { $0 == $1 }
    }
}
