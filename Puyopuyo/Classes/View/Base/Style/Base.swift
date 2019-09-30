//
//  ButtonStyle.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/28.
//

import Foundation

// MARK: - ViewSingleValueStyle
public class ViewSingleValueStyle<View, Value, KeyPath> where KeyPath: ReferenceWritableKeyPath<View, Value>, View: UIView {
    public var value: Value
    public var keyPath: KeyPath
    public init(value: Value, keyPath: KeyPath) {
        self.value = value
        self.keyPath = keyPath
    }
}

// MARK: - UIViewValueStyle
public class UIViewValueStyle<Value>: ViewSingleValueStyle<UIView, Value, ReferenceWritableKeyPath<UIView, Value>>, Style {
    public func apply(to styleable: Styleable) {
        guard let view = styleable as? UIView else {
            return
        }
        view[keyPath: self.keyPath] = value
    }
}

// MARK: - CommonValueStyle
open class CommonValueStyle<T, U>: Style {
    public var value: T
    public init(value: T) {
        self.value = value
    }
    public func apply(to styleable: Styleable) {
        if let s = StyleUtil.convert(styleable, U.self) {
            applyStyleable(s)
        }
    }
    
    public func applyStyleable(_ styleable: U) {
        
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
