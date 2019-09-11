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
            return from.outputing({ (x) in
                input.input(value: x)
            })
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
            let unbinders = outputs.map({ (o) -> Unbinder in
                return o.outputing({ (v) in
                    i.input(value: v)
                })
            })
            return Unbinders.create {
                unbinders.forEach({ $0.py_unbind() })
            }
        }
    }
}


extension Yo where Base: Outputing {
    
    public func some() -> SimpleOutput<Base.OutputType?> {
        return map({ $0 })
    }
    
    public func map<R>(_ block: @escaping (Base.OutputType) -> R) -> SimpleOutput<R> {
        return SimpleOutput<R>({ (input) -> Unbinder in
            return self.base.outputing({ (x) in
                input.input(value: block(x))
            })
        })
    }
    
    public func filter(_ filter: @escaping (Base.OutputType) -> Bool) -> SimpleOutput<Base.OutputType> {
        return SimpleOutput<Base.OutputType>({ (i) -> Unbinder in
            return self.base.outputing({ (x) in
                if filter(x) {
                    i.input(value: x)
                }
            })
        })
    }
    
    public func ignore(_ condition: @escaping (Base.OutputType, Base.OutputType) -> Bool) -> SimpleOutput<Base.OutputType> {
        var last: Base.OutputType!
        return SimpleOutput<Base.OutputType>({ (i) -> Unbinder in
            return self.base.outputing({ (x) in
                guard last != nil else {
                    last = x
                    i.input(value: x)
                    return
                }
                let ignore = condition(last, x)
                last = x
                if !ignore {
                    i.input(value: x)
                }
            })
        })
    }
    
}


public protocol PuyoOptionalType {
    associatedtype PuyoWrappedType
    var puyoWrapValue: PuyoWrappedType? { get }
}

extension Optional: PuyoOptionalType {
    public typealias PuyoWrappedType = Wrapped
    public var puyoWrapValue: Wrapped? {
        return self
    }
}

extension Yo where Base: Outputing, Base.OutputType: PuyoOptionalType {
    public func unwrap(or: Base.OutputType.PuyoWrappedType) -> SimpleOutput<Base.OutputType.PuyoWrappedType> {
        return SimpleOutput<Base.OutputType.PuyoWrappedType>({ (input) -> Unbinder in
            return self.base.outputing({ (value) in
                if let value = value.puyoWrapValue {
                    input.input(value: value)
                } else {
                    input.input(value: or)
                }
            })
        })
    }
}


extension Yo where Base: Outputing, Base.OutputType: Equatable {
    public func distinct() -> SimpleOutput<Base.OutputType> {
        return ignore({ $0 == $1 })
    }
}

extension PuyoOptionalType where PuyoWrappedType == Self {
    public var puyoWrapValue: PuyoWrappedType? {
        return Optional.some(self)
    }
}

extension String: PuyoOptionalType { public typealias PuyoWrappedType = String }
extension UIColor: PuyoOptionalType { public typealias PuyoWrappedType = UIColor }
extension UIFont: PuyoOptionalType { public typealias PuyoWrappedType = UIFont }
extension NSNumber: PuyoOptionalType { public typealias PuyoWrappedType = NSNumber }
