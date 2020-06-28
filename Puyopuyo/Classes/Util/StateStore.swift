//
//  StateStore.swift
//  Puyopuyo
//
//  Created by 王俊仁 on 2020/6/28.
//

import Foundation
import SwiftUI

public protocol StateStoreObject: AnyObject {
    associatedtype StoreOutputing: Outputing & Inputing where StoreOutputing.OutputType == (), StoreOutputing.InputType == StoreOutputing.OutputType

    var _changeOutput: StoreOutputing { get }

    var _unbinderBag: UnbinderBag { get }
}

public extension StateStoreObject {
    func trigger() {
        _changeOutput.input(value: ())
    }
}

public extension StateStoreObject {
    func onStoreChanged() -> SimpleOutput<Self> {
        _changeOutput.mapTo { self }
    }
}

open class AbstractStateStoreObject: StateStoreObject {
    public init() {}
    public var _changeOutput = SimpleIO<Void>()
    public var _unbinderBag: UnbinderBag = Unbinders.createBag()
    deinit {
        #if DEBUG
        print("StateStoreObject: <\(self)> deinit!!!")
        #endif
    }
}

protocol ChangeHandler {
    var didChange: SimpleOutput<Void> { get }
}

@propertyWrapper
public struct ChangeNotifier<Value>: ChangeHandler {
    private var notifier = SimpleIO<Void>()
    var didChange: SimpleOutput<Void> { notifier.asOutput() }
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public var wrappedValue: Value {
        didSet {
            notifier.input(value: ())
        }
    }
    
    public struct ObjectTrigger {
        var object: Value
        var after: () -> Void
        public func trigger(after action: (Value) -> Void) {
            action(object)
            after()
        }
    }
    public var projectedValue: ObjectTrigger {
        ObjectTrigger(object: wrappedValue) {
            self.notifier.input(value: ())
        }
    }
}

@propertyWrapper
@dynamicMemberLookup
public struct StateStore<ObjectType> where ObjectType: StateStoreObject {
    var storeObject: ObjectType
    public init(wrappedValue: ObjectType) {
        self.storeObject = wrappedValue
        let m = Mirror(reflecting: wrappedValue)
        m.children.forEach { c in
            if let value = c.value as? ChangeHandler {
                value.didChange.outputing { [weak wrappedValue] in
                    wrappedValue?.trigger()
                }.unbind(by: storeObject._unbinderBag)
            }
        }
    }

    public var wrappedValue: ObjectType {
        storeObject
    }

    public var projectedValue: StateBinding<ObjectType> {
        StateBinding(output: storeObject.onStoreChanged())
    }

    public subscript<U>(dynamicMember member: ReferenceWritableKeyPath<ObjectType, U>) -> StateBinding<U> {
        StateBinding<U>(output: storeObject.onStoreChanged().mapTo(member))
    }
}
