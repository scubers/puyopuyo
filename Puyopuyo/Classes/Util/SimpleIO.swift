//
//  SimpleIO.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/17.
//

import Foundation

public class SimpleIO<Value>: Inputing, Outputing {
    
    public typealias InputType = Value
    public typealias OutputType = Value
    
    private var inputers = [SimpleInput<Value>]()
    
    public init() {
    }
    
    public func input(value: Value) {
        inputers.forEach { (c) in
            c.input(value: value)
        }
    }
    
    public func outputing(_ block: @escaping (Value) -> Void) -> Unbinder {
        let inputer = SimpleInput(block)
        inputers.append(inputer)
        let id = inputer.uuid
        return UnbinderImpl { [weak self] in
            self?.inputers.removeAll(where: { $0.uuid == id })
        }
    }
    
    private class Callee<T> {
        var block: (T) -> Void
        init(_ block: @escaping (T) -> Void) {
            self.block = block
        }
    }
    
}
