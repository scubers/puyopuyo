//
//  Observer.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/8/18.
//

import Foundation


class _Observer<Value>: NSObject {
    var key: String = ""
    var change: (Value?) -> Void = { _ in }
    init(key: String, change: @escaping (Value?) -> Void) {
        super.init()
        self.key = key
        self.change = change
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == key {
            if let change = change {
                self.change(change[.newKey] as? Value)
            } else {
                self.change(nil)
            }
        }
    }
    #if DEBUG
    deinit {
        print("observer deinit")
    }
    #endif
}

extension NSObject {
    public func py_addObserver<Value: Equatable>(for keyPath: String, id: String, block: @escaping (Value?) -> Void) {
        var lastValue: Value?
        let observer = _Observer<Value>(key: keyPath) { (rect) in
            guard rect != lastValue else { return }
            lastValue = rect
            block(lastValue)
        }
        let unbinder = Unbinders.create { [weak self] in
            #if DEBUG
//            print("unbind keypath: \(keyPath)")
            #endif
            self?.removeObserver(observer, forKeyPath: keyPath)
        }
        addObserver(observer, forKeyPath: keyPath, options: [.new, .initial], context: nil)
        py_setUnbinder(unbinder, for: id)
    }
}

extension UIView {
    public func py_observeBounds<T>(_ block: @escaping (CGRect) -> T) -> State<T> {
        let s = State<T>(block(.zero))
        let id = "\(Date().timeIntervalSince1970)\(arc4random())"
        py_addObserver(for: #keyPath(UIView.bounds), id: id, block: { (rect: CGRect?) in
            let value = block(rect ?? .zero)
            s.postValue(value)
        })
        return s
    }
}
