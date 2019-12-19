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

    override func observeValue(forKeyPath keyPath: String?, of _: Any?, change: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
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
    
    public func py_observing<Value: Equatable>(for keyPath: String, id: String = UUID().description) -> SimpleOutput<Value?> {
        return SimpleOutput<Value?> { (i) -> Unbinder in
            var lastValue: Value?
            let observer = _Observer<Value>(key: keyPath) { rect in
                guard rect != lastValue else { return }
                lastValue = rect
                i.input(value: rect)
            }
            let unbinder = Unbinders.create { [unowned(unsafe) self] in
                self.removeObserver(observer, forKeyPath: keyPath)
//                self.py_removeUnbinder(for: id)?.py_unbind()
            }
            self.addObserver(observer, forKeyPath: keyPath, options: [.new, .initial], context: nil)
            self.py_setUnbinder(unbinder, for: id)
            return unbinder
        }
        .distinct()
        
    }
    
    public func py_identifier() -> String {
        return "\(Unmanaged.passRetained(self).toOpaque())"
    }
}
