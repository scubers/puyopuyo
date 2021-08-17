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

func _getOptionalType<T: OptionalableValueType, R>(from: String?) -> T where T.Wrap == R {
    return from as! T
}

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

extension String: OptionalableValueType { public typealias Wrap = String }
extension UIColor: OptionalableValueType { public typealias Wrap = UIColor }
extension UIFont: OptionalableValueType { public typealias Wrap = UIFont }
extension NSNumber: OptionalableValueType { public typealias Wrap = NSNumber }
extension UIImage: OptionalableValueType { public typealias Wrap = UIImage }
extension Date: OptionalableValueType { public typealias Wrap = Date }
extension Data: OptionalableValueType { public typealias Wrap = Data }
extension URL: OptionalableValueType { public typealias Wrap = URL }
