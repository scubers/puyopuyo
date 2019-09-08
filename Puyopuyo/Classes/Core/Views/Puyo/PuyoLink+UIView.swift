//
//  Puyo+UIView.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/1.
//

import Foundation

extension Puyo where T: UIView {
    
    @discardableResult
    public func backgroundColor<S: Outputing>(_ color: S) -> Self where S.OutputType == UIColor? {
        color.safeBind(to: view, id: #function) { (v, a) in
            v.backgroundColor = a
        }
        return self
    }
    
    @discardableResult
    public func contentMode<S: Outputing>(_ mode: S) -> Self where S.OutputType == UIView.ContentMode {
        mode.safeBind(to: view, id: #function) { (v, a) in
            v.contentMode = a
        }
        return self
    }
    
    @discardableResult
    public func clipToBounds<S: Outputing>(_ clip: S) -> Self where S.OutputType == Bool {
        clip.safeBind(to: view, id: #function) { (v, a) in
            v.clipsToBounds = a
        }
        return self
    }
    
    @discardableResult
    public func cornerRadius<S: Outputing>(_ radius: S) -> Self where S.OutputType == CGFloat {
        radius.safeBind(to: view, id: #function) { (v, a) in
            v.layer.cornerRadius = a
            v.clipsToBounds = true
        }
        return self
    }
    
    @discardableResult
    public func borderWidth<S: Outputing>(_ width: S) -> Self where S.OutputType == CGFloat {
        width.safeBind(to: view, id: #function) { (v, a) in
            v.layer.borderWidth = a
        }
        return self
    }
    
    @discardableResult
    public func borderColor<S: Outputing>(_ color: S) -> Self where S.OutputType == UIColor? {
        color.safeBind(to: view, id: #function) { (v, a) in
            v.layer.borderColor = a?.cgColor
        }
        return self
    }
    
    @discardableResult
    public func alpha<S: Outputing>(_ alpha: S) -> Self where S.OutputType == CGFloat {
        
        view.py_setUnbinder(alpha.safeBind(view, { (v, a) in
            v.alpha = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func userInteractionEnabled<S: Outputing>(_ enabled: S) -> Self where S.OutputType == Bool {
        view.py_setUnbinder(enabled.safeBind(view, { (v, a) in
            v.isUserInteractionEnabled = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func frame<S: Outputing>(_ frame: S) -> Self where S.OutputType == CGRect {
        view.py_setUnbinder(frame.safeBind(view, { (v, a) in
            v.frame = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func frame(x: CGFloat? = nil, y: CGFloat? = nil, w: CGFloat? = nil, h: CGFloat? = nil) -> Self {
        if let v = x { view.frame.origin.x = v }
        if let v = y { view.frame.origin.y = v }
        if let v = w { view.frame.size.width = v }
        if let v = h { view.frame.size.height = v }
        return self
    }

    
    @discardableResult
    public func bounds<S: Outputing>(_ frame: S) -> Self where S.OutputType == CGRect {
        view.py_setUnbinder(frame.safeBind(view, { (v, a) in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            v.bounds = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func center<S: Outputing>(_ point: S) -> Self where S.OutputType == CGPoint {
        view.py_setUnbinder(point.safeBind(view, { (v, a) in
            v.center = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func onBoundsChanged<O: Inputing>(_ bounds: O) -> Self where O.InputType == CGRect {
        _ = view.py_boundsState().send(to: bounds)
        return self
    }
    
    @discardableResult
    public func onCenterChanged<O: Inputing>(_ center: O) -> Self where O.InputType == CGPoint {
        _ = view.py_centerState().send(to: center)
        return self
    }
    
    @discardableResult
    public func onFrameChanged<O: Inputing>(_ frame: O) -> Self where O.InputType == CGRect {
        _ = view.py_frameStateByBoundsCenter().send(to: frame)
        _ = view.py_frameStateByKVO().send(to: frame)
        return self
    }
    
    @discardableResult
    public func frameX(_ x: ValueModifiable) -> Self {
        view.py_setUnbinder(x.checkSelfSimulate(view).modifyValue().safeBind(view, { (v, a) in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            v.frame.origin.x = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func frameY(_ y: ValueModifiable) -> Self {
        view.py_setUnbinder(y.checkSelfSimulate(view).modifyValue().safeBind(view, { (v, a) in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            v.frame.origin.y = a
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func frameWidth(_ width: ValueModifiable) -> Self {
        view.py_setUnbinder(width.checkSelfSimulate(view).modifyValue().safeBind(view, { (v, a) in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            v.frame.size.width = max(0, a)
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func frameHeight(_ width: ValueModifiable) -> Self {
        view.py_setUnbinder(width.checkSelfSimulate(view).modifyValue().safeBind(view, { (v, a) in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            v.frame.size.height = max(0, a)
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func top(_ top: ValueModifiable) -> Self {
        view.py_setUnbinder(top.modifyValue().safeBind(view, { (v, a) in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            var f = v.frame
            f.origin.y = a
            f.size.height = max(0, v.frame.maxY - a)
            v.frame = f
        }), for: #function)
        return self
    }
    
    
    @discardableResult
    public func left(_ left: ValueModifiable) -> Self {
        view.py_setUnbinder(left.modifyValue().safeBind(view, { (v, a) in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            var f = v.frame
            f.origin.x = a
            f.size.width = max(0, v.frame.maxX - a)
            v.frame = f
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func bottom(_ bottom: ValueModifiable) -> Self {
        view.py_setUnbinder(bottom.modifyValue().safeBind(view, { (v, a) in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            var f = v.frame
            f.size.height = max(0, a - v.frame.origin.y)
            v.frame = f
        }), for: #function)
        return self
    }
    
    @discardableResult
    public func right(_ right: ValueModifiable) -> Self {
        view.py_setUnbinder(right.modifyValue().safeBind(view, { (v, a) in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            var f = v.frame
            f.size.width = max(0, a - v.frame.origin.x)
            v.frame = f
        }), for: #function)
        return self
    }
    /*
    */
    
    @discardableResult
    public func onTap<Object: AnyObject>(to object: Object, _ action: @escaping (Object, UITapGestureRecognizer) -> Void) -> Self {
        view.py_setUnbinder(view.py_setTap(action: { [weak object] (tap) in
            if let o = object {
                action(o, tap)
            }
        }), for: UUID().description)
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
