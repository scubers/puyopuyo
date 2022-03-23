//
//  Disposer.swift
//  Puyopuyo
//
//  Created by J on 2022/3/23.
//

import Foundation

public protocol Disposer {
    func dispose()
}

public extension Disposer {
    func dispose(by: AutoDisposable, id: String? = nil) {
        by.addDisposer(self, for: id)
    }
}

public typealias DisposableBag = AutoDisposable
public protocol AutoDisposable: AnyObject {
    /// Batch dispose disposers when deinit
    func addDisposer(_ disposer: Disposer, for key: String?)
}

public typealias Unbinders = Disposers
public struct Disposers {
    private init() {}
    public static func create(_ block: @escaping () -> Void = {}) -> Disposer {
        return DisposableImpl(block)
    }

    public static func createBag() -> AutoDisposable {
        AutoDisposeBag()
    }

    private class DisposableImpl: Disposer {
        private var block: (() -> Void)?

        init(_ block: @escaping () -> Void) {
            self.block = block
        }

        func dispose() {
            block?()
            block = nil
        }
    }

    private class AutoDisposeBag: AutoDisposable {
        var anonymousDisposers = [Disposer]()
        var keyDisposers = [String: Disposer]()

        public func addDisposer(_ disposer: Disposer, for key: String?) {
            if let key = key {
                keyDisposers[key]?.dispose()
                keyDisposers[key] = disposer
            } else {
                anonymousDisposers.append(disposer)
            }
        }

        deinit {
            anonymousDisposers.forEach { $0.dispose() }
            keyDisposers.forEach { $1.dispose() }
        }
    }
}

extension NSObject: AutoDisposable {
    private static var py_autoDisposableKey = "py_autoDisposableKey"
    private var py_autoDisposable: AutoDisposable {
        var container = objc_getAssociatedObject(self, &NSObject.py_autoDisposableKey)
        if container == nil {
            container = Disposers.createBag()
            objc_setAssociatedObject(self, &NSObject.py_autoDisposableKey, container, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return container as! AutoDisposable
    }

    public func addDisposer(_ disposer: Disposer, for key: String?) {
        py_autoDisposable.addDisposer(disposer, for: key)
    }
}
