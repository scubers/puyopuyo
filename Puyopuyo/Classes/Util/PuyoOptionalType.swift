//
//  PuyoOptionalType.swift
//  Puyopuyo
//
//  Created by 王俊仁 on 2020/6/13.
//

import Foundation

public protocol PuyoOptionalType {
    associatedtype PuyoWrappedType
    var puyoWrapValue: PuyoWrappedType? { get }
}

func _getOptionalType<T: PuyoOptionalType, R>(from: String?) -> T where T.PuyoWrappedType == R {
    return from as! T
}

extension Optional: PuyoOptionalType {
    public typealias PuyoWrappedType = Wrapped
    public var puyoWrapValue: Wrapped? {
        return self
    }
}

extension PuyoOptionalType where PuyoWrappedType == Self {
    public var puyoWrapValue: PuyoWrappedType? {
        return Optional.some(self)
    }
}

extension String: PuyoOptionalType { public typealias PuyoWrappedType = String }
extension UIColor: PuyoOptionalType { public typealias PuyoWrappedType = UIColor }
extension UIFont: PuyoOptionalType { public typealias PuyoWrappedType = UIFont }
extension NSNumber: PuyoOptionalType { public typealias PuyoWrappedType = NSNumber }
extension UIImage: PuyoOptionalType { public typealias PuyoWrappedType = UIImage }
extension Date: PuyoOptionalType { public typealias PuyoWrappedType = Date }
extension Data: PuyoOptionalType { public typealias PuyoWrappedType = Data }
extension URL: PuyoOptionalType { public typealias PuyoWrappedType = URL }

