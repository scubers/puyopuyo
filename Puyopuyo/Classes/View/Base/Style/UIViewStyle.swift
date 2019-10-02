//
//  ButtonStyle.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/28.
//

import Foundation

// MARK: - SingleValueStyle
open class AnyReferenceKeyPathStyle<Object, DecorableType, Value, KeyPath>
    : Style
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
    open func applyDecorable(_ target: DecorableType) {
        
    }
}

// MARK: - UIViewStyle
public protocol UIViewDecorable: class {
    associatedtype View: UIView
    var decorableView: View { get }
}

extension UIViewDecorable where Self: UIView {
    public var decorableView: Self {
        return self
    }
}

extension UIView: UIViewDecorable {}

extension ReferenceWritableKeyPath where Root: UIView {
    public func getStyle(with value: Value) -> UIViewStyle<Root, Value> {
        return UIViewStyle<Root, Value>(keyPath: self, value: value)
    }
}

public class UIViewStyle<View: UIView, Value>: AnyReferenceKeyPathStyle<View, View, Value, ReferenceWritableKeyPath<View, Value>> {
    public override func applyDecorable(_ target: View) {
        target[keyPath: self.keyPath] = value
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
    
    public func applyDecorable(_ decroable: U) {
        
    }
}

// MARK: - UIControlBaseStyle
open class UIControlBaseStyle<T, U>: CommonValueStyle<T, U>, UIControlStatable {
    public var controlState: UIControl.State = .normal
    public init(value: T, state: UIControl.State = .normal) {
        super.init(value: value)
        self.controlState = state
    }
}
