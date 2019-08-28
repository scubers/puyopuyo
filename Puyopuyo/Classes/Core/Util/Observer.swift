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
    #if DEV
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
            s.input(value: value)
        })
        return s
    }
    
    public func py_observeCenter<T>(_ block: @escaping (CGPoint) -> T) -> State<T> {
        let s = State<T>(block(.zero))
        let id = "\(Date().timeIntervalSince1970)\(arc4random())"
        py_addObserver(for: #keyPath(UIView.center), id: id, block: { (point: CGPoint?) in
            let value = block(point ?? .zero)
            s.input(value: value)
        })
        return s

    }
    
    public func py_observeFrameByBoundsCenter<T>(_ block: @escaping (CGRect) -> T) -> State<T> {
        let s = State<T>(block(.zero))
        let id = "\(Date().timeIntervalSince1970)\(arc4random())"
        py_addObserver(for: #keyPath(UIView.bounds), id: "\(id)_bounds", block: { [weak self] (_: CGRect?) in
            if let self = self {
                let value = block(self.frame)
                s.input(value: value)
            } else {
                let value = block(.zero)
                s.input(value: value)
            }
        })
        py_addObserver(for: #keyPath(UIView.center), id: "\(id)_center", block: { [weak self] (_: CGPoint?) in
            if let self = self {
                let value = block(self.frame)
                s.input(value: value)
            } else {
                let value = block(.zero)
                s.input(value: value)
            }
        })
        return s
    }
}
