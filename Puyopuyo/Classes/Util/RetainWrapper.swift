//
//  RetainWrapper.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/15.
//

import UIKit

public class RetainWrapper<Wrapped: AnyObject> {
    private var retained = true
    weak var weakValue: Wrapped?
    var strongValue: Wrapped?

    public var value: Wrapped? { strongValue ?? weakValue }

    public init(value: Wrapped, retained: Bool = true) {
        self.retained = retained
        if retained {
            strongValue = value
        } else {
            weakValue = value
        }
    }
}

extension RetainWrapper: Unbinder {
    public func py_unbind() {}
}
