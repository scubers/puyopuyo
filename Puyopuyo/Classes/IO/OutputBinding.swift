//
//  OutputBinding.swift
//  Puyopuyo
//
//  Created by J on 2021/9/23.
//

import Foundation

@dynamicMemberLookup public struct OutputBinding<T>: Outputing, OutputingModifier {
    var output: Outputs<T>

    public subscript<R>(dynamicMember dynamicMember: KeyPath<T, R>) -> OutputBinding<R> {
        OutputBinding<R>(output: output.map(dynamicMember))
    }

    public func outputing(_ block: @escaping (T) -> Void) -> Disposer {
        output.outputing(block)
    }
}

public extension OutputBinding where T: OptionalableValueType {
    subscript<R: OptionalableValueType>(dynamicMember dynamicMember: KeyPath<T.Wrap, R>) -> OutputBinding<R.Wrap?> {
        OutputBinding<R.Wrap?>(output: output.map { v in
            if let v = v.optionalValue,
               let value = v[keyPath: dynamicMember].optionalValue
            {
                return value
            }
            return nil

        })
    }
}

@dynamicMemberLookup public class InputBinding<T, R>: Inputing {
    var value: T
    var keyPath: WritableKeyPath<T, R>
    public init(value: T, keyPath: WritableKeyPath<T, R>) {
        self.value = value
        self.keyPath = keyPath
    }

    public subscript<V>(dynamicMember dynamicMember: WritableKeyPath<R, V>) -> InputBinding<T, V> {
        let kp = keyPath.appending(path: dynamicMember)
        return InputBinding<T, V>(value: value, keyPath: kp)
    }

    public func input(value: R) {
        self.value[keyPath: keyPath] = value
    }
}
