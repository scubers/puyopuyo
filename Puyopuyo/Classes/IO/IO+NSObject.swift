//
//  IO+NSObject.swift
//  Puyopuyo
//
//  Created by J on 2021/8/24.
//

import Foundation

public extension _KeyValueCodingAndObserving where Self: AutoDisposable {
    /// Create a KVO listening, auto dispose when Self is deinit
    func py_observing<R>(_ keyPath: KeyPath<Self, R>) -> Outputs<R?> {
        return Outputs { i in
            let observer = self.observe(keyPath, options: .initial.union(.new)) { _, v in
                i.input(value: v.newValue)
            }
            let disposer = Disposers.create {
                observer.invalidate()
            }
            self.addDisposer(disposer, for: nil)
            return disposer
        }
    }
}

public extension NSObject {
    func py_observing<Value: Equatable>(for keyPath: String) -> Outputs<Value?> {
        return Outputs<Value?> { i -> Disposer in
            var lastValue: Value?
            let observer = _Observer<Value>(key: keyPath) { rect in
                guard rect != lastValue else { return }
                lastValue = rect
                i.input(value: rect)
            }
            let disposer = Disposers.create { [unowned(unsafe) self] in
                self.removeObserver(observer, forKeyPath: keyPath)
            }
            self.addObserver(observer, forKeyPath: keyPath, options: [.new, .initial], context: nil)
            self.addDisposer(disposer, for: nil)
            return disposer
        }
        .distinct()
    }
}

// MARK: - Private

private class _Observer<Value>: NSObject {
    var key: String = ""
    var change: (Value?) -> Void = { _ in }
    init(key: String, change: @escaping (Value?) -> Void) {
        super.init()
        self.key = key
        self.change = change
    }

    override func observeValue(forKeyPath keyPath: String?, of _: Any?, change: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
        if keyPath == key {
            if let change = change {
                self.change(change[.newKey] as? Value)
            } else {
                self.change(nil)
            }
        }
    }
}
