//
//  SimpleOutput.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/8.
//

import Foundation

public typealias SimpleOutput = Outputs
public struct Outputs<Value>: Outputing, OutputingModifier {
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

    public func subscribe<Subscriber>(_ subscriber: Subscriber) -> Disposer where Subscriber: Inputing, Value == Subscriber.InputType {
        let input = Inputs<Value> { subscriber.input(value: $0) }
        return action(input)
    }
}

// MARK: - Creations

public extension Outputs {
    static func just(_ value: Value) -> Outputs<Value> {
        Outputs {
            $0.input(value: value)
            return Disposers.create()
        }
    }

    static func merge<T: Outputing>(_ outputs: [T]) -> Outputs<Value> where T.OutputType == Value {
        Outputs<Value> { i -> Disposer in
            let disposables = outputs.map { o -> Disposer in
                o.outputing { v in
                    i.input(value: v)
                }
            }
            return Disposers.create {
                disposables.forEach { $0.dispose() }
            }
        }
    }
}

public extension Outputs where Self.OutputType == Any {
    static func combine<O1, O2>(_ o1: O1, _ o2: O2) -> Outputs<(O1.OutputType, O2.OutputType)> where O1: Outputing, O2: Outputing {
        Outputs<(O1.OutputType, O2.OutputType)> { i in
            var o1Done = false
            var o2Done = false

            var o1Value: O1.OutputType?
            var o2Value: O2.OutputType?

            func executeNext() {
                if o1Done, o2Done {
                    i.input(value: (o1Value!, o2Value!))
                }
            }

            let disposer = o1.outputing { o in
                o1Value = o
                o1Done = true
                executeNext()
            }

            let disposer2 = o2.outputing { o in
                o2Value = o
                o2Done = true
                executeNext()
            }

            return Disposers.create {
                disposer.dispose()
                disposer2.dispose()
            }
        }
    }

    static func combine<O1, O2, O3>(_ o1: O1, _ o2: O2, _ o3: O3) -> Outputs<(O1.OutputType, O2.OutputType, O3.OutputType)> where O1: Outputing, O2: Outputing, O3: Outputing {
        Outputs.combine(o1, o2).combine(o3).map { o1, last in
            (o1.0, o1.1, last)
        }
    }

    static func combine<O1, O2, O3, O4>(_ o1: O1, _ o2: O2, _ o3: O3, _ o4: O4) -> Outputs<(O1.OutputType, O2.OutputType, O3.OutputType, O4.OutputType)> where O1: Outputing, O2: Outputing, O3: Outputing, O4: Outputing {
        Outputs.combine(o1, o2, o3).combine(o4).map { o, last in
            (o.0, o.1, o.2, last)
        }
    }

    static func combine<O1, O2, O3, O4, O5>(_ o1: O1, _ o2: O2, _ o3: O3, _ o4: O4, _ o5: O5) -> Outputs<(O1.OutputType, O2.OutputType, O3.OutputType, O4.OutputType, O5.OutputType)> where O1: Outputing, O2: Outputing, O3: Outputing, O4: Outputing, O5: Outputing {
        Outputs.combine(o1, o2, o3, o4).combine(o5).map { o, last in
            (o.0, o.1, o.2, o.3, last)
        }
    }

    static func combine<O1, O2, O3, O4, O5, O6>(_ o1: O1, _ o2: O2, _ o3: O3, _ o4: O4, _ o5: O5, _ o6: O6) -> Outputs<(O1.OutputType, O2.OutputType, O3.OutputType, O4.OutputType, O5.OutputType, O6.OutputType)> where O1: Outputing, O2: Outputing, O3: Outputing, O4: Outputing, O5: Outputing, O6: Outputing {
        Outputs.combine(o1, o2, o3, o4, o5).combine(o6).map { o, last in
            (o.0, o.1, o.2, o.3, o.4, last)
        }
    }

    static func combine<O>(_ outputs: [O]) -> Outputs<[O.OutputType]> where O: Outputing {
        let total: Int = 64
        if outputs.count > total {
            fatalError("Outputs.combine(outputs) can not more than \(total), current: \(outputs.count)")
        }
        return Outputs<[O.OutputType]> { i in

            let flag: UInt64 = ~0

            var result: UInt64 = (flag << outputs.count)

            var values: [O.OutputType?] = Array(repeating: nil, count: outputs.count)

            let lock = NSObject()

            let dos = outputs.enumerated().map { offset, element in
                element.outputing { o in

                    objc_sync_enter(lock)
                    defer { objc_sync_exit(lock) }

                    values[offset] = o
                    result |= (1 << offset)

                    if flag == result {
                        i.input(value: values.map { $0! })
                    }
                }
            }

            return Disposers.create {
                dos.forEach { $0.dispose() }
            }
        }
    }
}
