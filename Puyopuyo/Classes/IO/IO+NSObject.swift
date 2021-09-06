//
//  IO+NSObject.swift
//  Puyopuyo
//
//  Created by J on 2021/8/24.
//

import Foundation

public extension _KeyValueCodingAndObserving where Self: DisposableBag {
    func py_observing<R>(_ keyPath: KeyPath<Self, R>) -> Outputs<R?> {
        return Outputs { i in
            let observer = observe(keyPath, options: .initial.union(.new)) { _, v in
                i.input(value: v.newValue)
            }
            let disposer = Disposers.create {
                observer.invalidate()
            }
            addDisposer(disposer, for: nil)
            return disposer
        }
    }
}

extension NSObject: DisposableBag {
    public func addDisposer(_ disposer: Disposer, for key: String?) {
        py_disposerContainer.setDisposable(disposer, for: key)
    }

    @discardableResult
    private func py_removeDisposable(for key: String) -> Disposer? {
        return py_disposerContainer.removeDisposable(for: key)
    }

    private static var py_disposableContainerKey = "py_puyoDisposable"
    private var py_disposerContainer: DisposableContainer {
        var container = objc_getAssociatedObject(self, &NSObject.py_disposableContainerKey)
        if container == nil {
            container = DisposableContainer()
            objc_setAssociatedObject(self, &NSObject.py_disposableContainerKey, container, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return container as! DisposableContainer
    }

    private class DisposableContainer: NSObject {
        private var disposers = [String: Disposer]()
        private var list = [Disposer]()

        func setDisposable(_ disposer: Disposer, for key: String?) {
            if let key = key {
                let old = disposers[key]
                old?.dispose()
                disposers[key] = disposer
            } else {
                list.append(disposer)
            }
        }

        func removeDisposable(for key: String) -> Disposer? {
            return disposers.removeValue(forKey: key)
        }

        deinit {
            disposers.forEach { $1.dispose() }
            list.forEach { $0.dispose() }
        }
    }
}

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
