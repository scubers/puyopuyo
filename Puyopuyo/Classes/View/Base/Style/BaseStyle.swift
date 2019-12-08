//
//  ButtonStyle.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/28.
//

import Foundation

// MARK: - AnyReferenceKeyPathStyle

open class AnyReferenceKeyPathStyle<Object, DecorableType, Value, KeyPath>:
    Style
    where KeyPath: ReferenceWritableKeyPath<Object, Value>, Object: AnyObject {
    public var value: Value
    public var keyPath: KeyPath
    public init(value: Value, keyPath: KeyPath) {
        self.value = value
        self.keyPath = keyPath
    }

    public init(keyPath: KeyPath, value: Value) {
        self.value = value
        self.keyPath = keyPath
    }

    public func apply(to decorable: Decorable) {
        if let target = decorable as? DecorableType {
            applyDecorable(target)
        }
    }

    open func applyDecorable(_: DecorableType) {}
}

// MARK: - NSObjectDecorable

public class NSObjectStyle<Object: NSObject, Value>: AnyReferenceKeyPathStyle<Object, Object, Value, ReferenceWritableKeyPath<Object, Value>> {
    public override func applyDecorable(_ target: Object) {
        target[keyPath: self.keyPath] = value
    }
}

extension ReferenceWritableKeyPath where Root: NSObject {
    public func getStyle(with value: Value) -> NSObjectStyle<Root, Value> {
        return NSObjectStyle<Root, Value>(keyPath: self, value: value)
    }
}

// MARK: - CommonValueStyle

open class CommonValueStyle<T, U>: Style {
    public var value: T
    public init(value: T) {
        self.value = value
    }

    public func apply(to decroable: Decorable) {
        if let s = StyleUtil.convert(decroable, U.self) {
            applyDecorable(s)
        }
    }

    public func applyDecorable(_: U) {}
}

// MARK: - UIControlBaseStyle

public protocol UIControlStatable {
    var controlState: UIControl.State { get }
}

open class UIControlBaseStyle<T, U>: CommonValueStyle<T, U>, UIControlStatable {
    public var controlState: UIControl.State = .normal
    public init(value: T, state: UIControl.State = .normal) {
        super.init(value: value)
        controlState = state
    }
}
