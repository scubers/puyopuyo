//
//  OutputBinding.swift
//  Puyopuyo
//
//  Created by J on 2021/9/23.
//

import Foundation

@dynamicMemberLookup public struct OutputBinder<T>: Outputing, OutputingModifier {
    var output: Outputs<T>

    public subscript<R>(dynamicMember dynamicMember: KeyPath<T, R>) -> OutputBinder<R> {
        OutputBinder<R>(output: output.map(dynamicMember))
    }

    public func outputing(_ block: @escaping (T) -> Void) -> Disposer {
        output.outputing(block)
    }
}

public extension OutputBinder where T: OptionalableValueType {
    subscript<R: OptionalableValueType>(dynamicMember dynamicMember: KeyPath<T.Wrap, R>) -> OutputBinder<R.Wrap?> {
        OutputBinder<R.Wrap?>(output: output.map { v in
            if let v = v.optionalValue,
               let value = v[keyPath: dynamicMember].optionalValue
            {
                return value
            }
            return nil

        })
    }
}
