//
//  IO+NotificationCenter.swift
//  Puyopuyo
//
//  Created by J on 2021/9/18.
//

import Foundation

public extension Outputs where OutputType == Any {
    static func listen(to name: Notification.Name, object: Any? = nil, queue: OperationQueue? = nil) -> Outputs<Notification> {
        return Outputs<Notification> { i in
            let binder = NotificationCenter.default.addObserver(forName: name, object: object, queue: queue) {
                i.input(value: $0)
            }
            return Disposers.create { _ = binder }
        }
    }
}
