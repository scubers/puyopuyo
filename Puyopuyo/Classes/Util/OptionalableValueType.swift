//
//  OptionalableValueType.swift
//  Puyopuyo
//
//  Created by 王俊仁 on 2020/6/13.
//

import Foundation

public protocol OptionalableValueType {
    associatedtype Wrap
    var optionalValue: Wrap? { get }
}

// MARK: - Extensions

extension Optional: OptionalableValueType {
    public typealias Wrap = Wrapped
    public var optionalValue: Wrapped? {
        return self
    }
}

public extension OptionalableValueType where Wrap == Self {
    var optionalValue: Wrap? {
        return Optional.some(self)
    }
}

public extension OptionalableValueType {
    subscript<Subject>(dynamicMember member: KeyPath<Wrap, Subject>) -> Subject? {
        if let v = optionalValue {
            return v[keyPath: member]
        }
        return nil
    }
}

extension String: OptionalableValueType { public typealias Wrap = String }
extension UIColor: OptionalableValueType { public typealias Wrap = UIColor }
extension UIFont: OptionalableValueType { public typealias Wrap = UIFont }
extension NSNumber: OptionalableValueType { public typealias Wrap = NSNumber }
extension UIImage: OptionalableValueType { public typealias Wrap = UIImage }
extension Date: OptionalableValueType { public typealias Wrap = Date }
extension Data: OptionalableValueType { public typealias Wrap = Data }
extension URL: OptionalableValueType { public typealias Wrap = URL }
