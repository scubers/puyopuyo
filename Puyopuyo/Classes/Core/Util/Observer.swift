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
        let unbinder = Unbinders.create { [unowned(unsafe) self] in
            self.removeObserver(observer, forKeyPath: keyPath)
        }
        addObserver(observer, forKeyPath: keyPath, options: [.new, .initial], context: nil)
        py_setUnbinder(unbinder, for: id)
    }
    
}

extension UIView {
    
    public func py_boundsState() -> SimpleOutput<CGRect> {
        let s = State<CGRect>(.zero)
        let id = UUID().description
        py_addObserver(for: #keyPath(UIView.bounds), id: id, block: { (rect: CGRect?) in
            s.input(value: rect ?? .zero)
        })
        return s.yo.distinct()
    }
    
    public func py_centerState() -> SimpleOutput<CGPoint> {
        let s = State<CGPoint>(.zero)
        let id = UUID().description
        py_addObserver(for: #keyPath(UIView.center), id: id, block: { (point: CGPoint?) in
            s.input(value: point ?? .zero)
        })
        return s.yo.distinct()
    }
    
    public func py_frameStateByBoundsCenter() -> SimpleOutput<CGRect> {
        let s = State(CGRect.zero)
        py_addObserver(for: #keyPath(UIView.bounds), id: UUID().description, block: { [weak self] (_: CGRect?) in
            if let self = self {
                s.input(value: self.frame)
            }
        })
        py_addObserver(for: #keyPath(UIView.center), id: UUID().description, block: { [weak self] (_: CGPoint?) in
            if let self = self {
                s.input(value: self.frame)
            }
        })
        // 因为这里是合并，不知道为何不能去重
        return s.yo.filter({_ in true})
    }
    
    public func py_frameStateByKVO() -> SimpleOutput<CGRect> {
        let s = State<CGRect>(.zero)
        py_addObserver(for: #keyPath(UIView.frame), id: UUID().description, block: { (rect: CGRect?) in
            if let value = rect {
                s.input(value: value)
            }
        })
        return s.yo.distinct()
    }
}
