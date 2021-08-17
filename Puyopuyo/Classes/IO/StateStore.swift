//
//  StateStore.swift
//  Puyopuyo
//
//  Created by 王俊仁 on 2020/6/28.
//

import Foundation
import SwiftUI

// MARK: - StateStore

public protocol StateStoreObject: AnyObject {
    init()
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
    public required init() {}
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
public class ChangeNotifier<Value>: ChangeHandler {
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
        ObjectTrigger(object: wrappedValue) { [weak self] in
            guard let self = self else { return }
            self.notifier.input(value: ())
        }
    }
}

@propertyWrapper
@dynamicMemberLookup
public struct StateStore<ObjectType> where ObjectType: StateStoreObject {
    var storeObject: ObjectType
    public init(wrappedValue: ObjectType) {
        storeObject = wrappedValue
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

    public subscript<U>(dynamicMember member: KeyPath<ObjectType, U>) -> StateBinding<U> {
        StateBinding<U>(output: storeObject.onStoreChanged().mapTo(member))
    }
}

// MARK: - GlobalStore

class _GlobalStore {
    static let shared = _GlobalStore()
    private init() {}
    class Holder {
        weak var object: AnyObject?
        init(obj: AnyObject) {
            object = obj
        }
    }

    private var map = [String: Holder]()

    func get<T: StateStoreObject>(id: String, or: () -> T) -> T {
        sync {
            if let obj = map[id]?.object as? T {
                return obj
            }
            let obj = or()
            let holder = Holder(obj: obj)
            map[id] = holder
            return obj
        }
    }

    private func sync<R>(_ action: () -> R) -> R {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        return action()
    }
}

@propertyWrapper
@dynamicMemberLookup
public struct GlobalStore<ObjectType> where ObjectType: StateStoreObject {
    private var storeObject: ObjectType
    public init() {
        storeObject = _GlobalStore.shared.get(id: "\(ObjectType.self)", or: {
            let obj = ObjectType()
            let m = Mirror(reflecting: obj)
            m.children.forEach { c in
                if let value = c.value as? ChangeHandler {
                    value.didChange.outputing { [weak obj] in
                        obj?.trigger()
                    }.unbind(by: obj._unbinderBag)
                }
            }
            return obj
        })
    }

    public var wrappedValue: ObjectType {
        storeObject
    }

    public var projectedValue: StateBinding<ObjectType> {
        StateBinding(output: storeObject.onStoreChanged())
    }

    public subscript<U>(dynamicMember member: KeyPath<ObjectType, U>) -> StateBinding<U> {
        StateBinding<U>(output: storeObject.onStoreChanged().mapTo(member))
    }
}
