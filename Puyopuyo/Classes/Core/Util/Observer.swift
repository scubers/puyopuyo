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
    public func py_observing<Value: Equatable>(for keyPath: String) -> SimpleOutput<Value?> {
        return SimpleOutput<Value?> { (i) -> Unbinder in
            var lastValue: Value?
            let observer = _Observer<Value>(key: keyPath) { (rect) in
                guard rect != lastValue else { return }
                lastValue = rect
                i.input(value: rect)
            }
            let unbinder = Unbinders.create { [unowned(unsafe) self] in
                self.removeObserver(observer, forKeyPath: keyPath)
            }
            self.addObserver(observer, forKeyPath: keyPath, options: [.new, .initial], context: nil)
            self.py_setUnbinder(unbinder, for: UUID().description)
            return unbinder
        }
        .yo.distinct()
    }
    
}

extension UIView {
    
    public func py_boundsState() -> SimpleOutput<CGRect> {
        return
            py_observing(for: #keyPath(UIView.bounds))
                .yo.map({ (rect: CGRect?) in rect ?? .zero})
                .yo.distinct()
    }
    
    public func py_centerState() -> SimpleOutput<CGPoint> {
        return
            py_observing(for: #keyPath(UIView.center))
                .yo.map({ (x: CGPoint?) in x ?? .zero})
                .yo.distinct()
    }
    
    public func py_frameStateByBoundsCenter() -> SimpleOutput<CGRect> {
        
        let bounds = py_boundsState().yo.map({_ in CGRect.zero})
        let center = py_centerState().yo.map({_ in CGRect.zero})
        return
            SimpleOutput.merge([bounds, center])
                .yo.map({ [weak self] (_) -> CGRect in
                    guard let self = self else { return .zero }
                    return self.frame
                })
        // 因为这里是合并，不知道为何不能去重
    }
    
    public func py_frameStateByKVO() -> SimpleOutput<CGRect> {
        return
            py_observing(for: #keyPath(UIView.frame))
                .yo.map({ (x: CGRect?) in x ?? .zero})
                .yo.distinct()
    }
}
