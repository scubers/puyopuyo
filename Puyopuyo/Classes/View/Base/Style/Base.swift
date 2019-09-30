//
//  ButtonStyle.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/28.
//

import Foundation

// MARK: - SingleValueStyle
open class SingleValueStyle<Object, Value, KeyPath> where KeyPath: ReferenceWritableKeyPath<Object, Value>, Object: AnyObject {
    public var value: Value
    public var keyPath: KeyPath
    public init(value: Value, keyPath: KeyPath) {
        self.value = value
        self.keyPath = keyPath
    }
}

// MARK: - UIViewStyle
public protocol UIViewDecorable {
    var decorableView: UIView { get }
}
extension UIView: UIViewDecorable {
    public var decorableView: UIView {
        return self
    }
}

public class UIViewStyle<Value>: SingleValueStyle<UIView, Value, ReferenceWritableKeyPath<UIView, Value>>, Style {
    public func apply(to decorable: Decorable) {
        guard let view = (decorable as? UIViewDecorable)?.decorableView else {
            return
        }
        view[keyPath: self.keyPath] = value
    }
}

// MARK: - CALayerStyle
public class CALayerStyle<Value>: SingleValueStyle<CALayer, Value, ReferenceWritableKeyPath<CALayer, Value>>, Style {
    public func apply(to decorable: Decorable) {
        guard let layer = (decorable as? UIViewDecorable)?.decorableView.layer else {
            return
        }
        layer[keyPath: self.keyPath] = value
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
