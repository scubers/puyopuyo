//
//  Loopup.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/6/29.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift
import Puyopuyo

extension BehaviorSubject: Stateful {
    
    public func py_bind(stateChange block: @escaping (Element) -> Void) -> Unbinder {
        let dispoer = subscribe(onNext: {
            block($0)
        })
        return Unbinders.create {
            dispoer.dispose()
        }
    }
    
    public func py_change(_ state: Element) {
        onNext(state)
    }
    
    public typealias StateType = Element
    
    
}


class Person {
    var name: String = ""
    var age: Int = 0
}

@dynamicMemberLookup
class Delegate {
    
    var person: Person
    init(_ person: Person) {
        self.person = person
    }
    
    subscript(dynamicMember member: String) -> String {
        return person[keyPath: \Person.name]
    }
    
    subscript(dynamicMember member: String) -> Int {
        return person[keyPath: \Person.age]
    }
    
    
    
    func test() {
    }
    
}

@dynamicCallable
class Call {
    func dynamicallyCall(withArguments args: [Int]) -> Double {
        return Double(args[0] + args[1])
    }
    
    func dynamicallyCall(withKeywordArguments args: KeyValuePairs<String, Int>) -> Double {
        return 0
    }
}

