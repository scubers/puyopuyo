//
//  PuyoLink+UIView.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/1.
//

import Foundation

extension PuyoLink where T: UIView {
    
    @discardableResult
    public func backgroundColor<S: Valuable>(_ color: S) -> Self where S.ValueType == UIColor? {
        view.py_setUnbinder(color.safeBind(view, { (v, a) in
            v.backgroundColor = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func contentMode<S: Valuable>(_ mode: S) -> Self where S.ValueType == UIView.ContentMode {
        view.py_setUnbinder(mode.safeBind(view, { (v, a) in
            v.contentMode = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func clipToBounds<S: Valuable>(_ clip: S) -> Self where S.ValueType == Bool {
        view.py_setUnbinder(clip.safeBind(view, { (v, a) in
            v.clipsToBounds = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func cornerRadius<S: Valuable>(_ radius: S) -> Self where S.ValueType == CGFloat {
        view.py_setUnbinder(radius.safeBind(view, { (v, a) in
            v.layer.cornerRadius = a
            v.clipsToBounds = true
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func borderWidth<S: Valuable>(_ width: S) -> Self where S.ValueType == CGFloat {
        view.py_setUnbinder(width.safeBind(view, { (v, a) in
            v.layer.borderWidth = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func borderColor<S: Valuable>(_ color: S) -> Self where S.ValueType == UIColor? {
        view.py_setUnbinder(color.safeBind(view, { (v, a) in
            v.layer.borderColor = a?.cgColor
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func alpha<S: Valuable>(_ alpha: S) -> Self where S.ValueType == CGFloat {
        view.py_setUnbinder(alpha.safeBind(view, { (v, a) in
            v.alpha = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func userInteractionEnabled<S: Valuable>(_ enabled: S) -> Self where S.ValueType == Bool {
        view.py_setUnbinder(enabled.safeBind(view, { (v, a) in
            v.isUserInteractionEnabled = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func frame<S: Valuable>(_ frame: S) -> Self where S.ValueType == CGRect {
        view.py_setUnbinder(frame.safeBind(view, { (v, a) in
            v.frame = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func bounds<S: Valuable>(_ frame: S) -> Self where S.ValueType == CGRect {
        view.py_setUnbinder(frame.safeBind(view, { (v, a) in
            v.bounds = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func center<S: Valuable>(_ frame: S) -> Self where S.ValueType == CGPoint {
        view.py_setUnbinder(frame.safeBind(view, { (v, a) in
            v.center = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func onBoundsChanged<O: Outputable>(_ bounds: O) -> Self where O.OutputType == CGRect {
        _ = view.py_observeBounds({ $0 }).py_bind(to: bounds)
        return self
    }
    
    @discardableResult
    public func onCenterChanged<O: Outputable>(_ center: O) -> Self where O.OutputType == CGPoint {
        _ = view.py_observeCenter({ $0 }).py_bind(to: center)
        return self
    }
    
    @discardableResult
    public func onFrameChanged<O: Outputable>(_ frame: O) -> Self where O.OutputType == CGRect {
        _ = view.py_observeFrameByBoundsCenter({ $0 }).py_bind(to: frame)
        return self
    }
    
    @discardableResult
    public func xPos(_ x: PositionModifiable) -> Self {
        view.py_setUnbinder(x.modifyPosition().safeBind(view, { (v, a) in
            v.frame.origin.x = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func yPos(_ y: PositionModifiable) -> Self {
        view.py_setUnbinder(y.modifyPosition().safeBind(view, { (v, a) in
            v.frame.origin.y = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func top(_ top: PositionModifiable) -> Self {
        view.py_setUnbinder(top.modifyPosition().safeBind(view, { (v, a) in
            var f = v.frame
            f.size.height = max(0, v.frame.maxY - a)
            f.origin.y = min(f.maxY, a)
            v.frame = f
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func left(_ left: PositionModifiable) -> Self {
        view.py_setUnbinder(left.modifyPosition().safeBind(view, { (v, a) in
            var f = v.frame
            f.size.width = max(0, v.frame.maxX - a)
            f.origin.x = min(f.maxX, a)
            v.frame = f
        }), for: #function)
        return self
    }
    
    @discardableResult
//    public func bottom<S: Valuable>(_ x: S) -> Self where S.ValueType == CGFloat {
    public func bottom(_ bottom: PositionModifiable) -> Self {
        view.py_setUnbinder(bottom.modifyPosition().safeBind(view, { (v, a) in
            var f = v.frame
            f.size.height = max(0, a - v.frame.origin.y)
            v.frame = f
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func right(_ right: PositionModifiable) -> Self {
        view.py_setUnbinder(right.modifyPosition().safeBind(view, { (v, a) in
            var f = v.frame
            f.size.width = max(0, a - v.frame.origin.x)
            v.frame = f
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func onTap<Object: AnyObject>(to object: Object, _ action: @escaping (Object, UITapGestureRecognizer) -> Void) -> Self {
        _ = view.py_setTap { [weak object] (tap) in
            if let o = object {
                action(o, tap)
            }
        }
        return self
    }
    
    @discardableResult
    public func tag(_ tag: Int) -> Self {
        view.tag = tag
        return self
    }
    
}

class _PuyoTapTarget<Tap>: NSObject, Unbinder {
    
    var action: (Tap) -> Void
    init(_ action: @escaping (Tap) -> Void) {
        self.action = action
    }
    
    @objc func targetAction(_ btn: Any) {
        action(btn as! Tap)
    }
    
    func py_unbind() {
        
    }
}

extension UIView {
    public func py_setTap(action: @escaping (UITapGestureRecognizer) -> Void) -> Unbinder {
        let target = _PuyoTapTarget<UITapGestureRecognizer>(action)
        let tap = UITapGestureRecognizer(target: target, action: #selector(_PuyoTapTarget<UITapGestureRecognizer>.targetAction(_:)))
        addGestureRecognizer(tap)
        let unbinder = Unbinders.create { [weak self] in
            self?.removeGestureRecognizer(tap)
        }
        py_setUnbinder(target, for: #function)
        return unbinder
    }
}
