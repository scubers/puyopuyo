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
            return Disposers.create {
                disposables.forEach { $0.dispose() }
            }
        }
    }

    public static func only(_ value: Value) -> Outputs<Value> {
        .init {
            $0.input(value: value)
            return Disposers.create()
        }
    }
}
