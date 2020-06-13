//
//  Puyo+UIView.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/1.
//

import Foundation

public extension Puyo where T: UIView {
    @discardableResult
    func backgroundColor<S: Outputing>(_ color: S) -> Self where S.OutputType: PuyoOptionalType, S.OutputType.PuyoWrappedType == UIColor {
        color.safeBind(to: view, id: #function) { v, a in
            v.backgroundColor = a.puyoWrapValue
        }
        return self
    }

    @discardableResult
    func contentMode<S: Outputing>(_ mode: S) -> Self where S.OutputType == UIView.ContentMode {
        mode.safeBind(to: view, id: #function) { v, a in
            v.contentMode = a
        }
        return self
    }

    @discardableResult
    func contentMode(_ mode: UIView.ContentMode) -> Self {
        view.contentMode = mode
        return self
    }

    @discardableResult
    func clipToBounds<S: Outputing>(_ clip: S) -> Self where S.OutputType == Bool {
        clip.safeBind(to: view, id: #function) { v, a in
            v.clipsToBounds = a
        }
        return self
    }

    @discardableResult
    func cornerRadius<S: Outputing>(_ radius: S) -> Self where S.OutputType: CGFloatable {
        radius.safeBind(to: view, id: #function) { v, a in
            v.layer.cornerRadius = a.cgFloatValue
            v.clipsToBounds = true
        }
        return self
    }

    @discardableResult
    func borderWidth<S: Outputing>(_ width: S) -> Self where S.OutputType: CGFloatable {
        width.safeBind(to: view, id: #function) { v, a in
            v.layer.borderWidth = a.cgFloatValue
        }
        return self
    }

    @discardableResult
    func borderColor<S: Outputing>(_ color: S) -> Self where S.OutputType: PuyoOptionalType, S.OutputType.PuyoWrappedType == UIColor {
        color.safeBind(to: view, id: #function) { v, a in
            v.layer.borderColor = a.puyoWrapValue?.cgColor
        }
        return self
    }

    @discardableResult
    func alpha<S: Outputing>(_ alpha: S) -> Self where S.OutputType == CGFloat {
        view.py_setUnbinder(alpha.catchObject(view) { v, a in
            v.alpha = a
        }, for: #function)
        return self
    }

    @discardableResult
    func userInteractionEnabled<S: Outputing>(_ enabled: S) -> Self where S.OutputType == Bool {
        view.py_setUnbinder(enabled.catchObject(view) { v, a in
            v.isUserInteractionEnabled = a
        }, for: #function)
        return self
    }

    @discardableResult
    func frame<S: Outputing>(_ frame: S) -> Self where S.OutputType == CGRect {
        view.py_setUnbinder(frame.catchObject(view) { v, a in
            v.frame = a
        }, for: #function)
        return self
    }

    @discardableResult
    func frame(x: CGFloat? = nil, y: CGFloat? = nil, w: CGFloat? = nil, h: CGFloat? = nil) -> Self {
        if let v = x { view.frame.origin.x = v }
        if let v = y { view.frame.origin.y = v }
        if let v = w { view.frame.size.width = v }
        if let v = h { view.frame.size.height = v }
        return self
    }

    @discardableResult
    func bounds<S: Outputing>(_ frame: S) -> Self where S.OutputType == CGRect {
        view.py_setUnbinder(frame.catchObject(view) { v, a in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            v.bounds = a
        }, for: #function)
        return self
    }

    @discardableResult
    func center<S: Outputing>(_ point: S) -> Self where S.OutputType == CGPoint {
        view.py_setUnbinder(point.catchObject(view) { v, a in
            v.center = a
        }, for: #function)
        return self
    }

    @discardableResult
    func onBoundsChanged<O: Inputing>(_ bounds: O) -> Self where O.InputType == CGRect {
        _ = view.py_boundsState().send(to: bounds)
        return self
    }

    @discardableResult
    func onCenterChanged<O: Inputing>(_ center: O) -> Self where O.InputType == CGPoint {
        _ = view.py_centerState().send(to: center)
        return self
    }

    @discardableResult
    func onFrameChanged<O: Inputing>(_ frame: O) -> Self where O.InputType == CGRect {
        _ = view.py_frameStateByBoundsCenter().send(to: frame)
        _ = view.py_frameStateByKVO().send(to: frame)
        return self
    }

    @discardableResult
    func frameX(_ x: ValueModifiable) -> Self {
        view.py_setUnbinder(x.checkSelfSimulate(view).modifyValue().catchObject(view) { v, a in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            v.frame.origin.x = a
        }, for: #function)
        return self
    }

    @discardableResult
    func frameY(_ y: ValueModifiable) -> Self {
        view.py_setUnbinder(y.checkSelfSimulate(view).modifyValue().catchObject(view) { v, a in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            v.frame.origin.y = a
        }, for: #function)
        return self
    }

    @discardableResult
    func frameWidth(_ width: ValueModifiable) -> Self {
        view.py_setUnbinder(width.checkSelfSimulate(view).modifyValue().catchObject(view) { v, a in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            v.frame.size.width = max(0, a)
        }, for: #function)
        return self
    }

    @discardableResult
    func frameHeight(_ width: ValueModifiable) -> Self {
        view.py_setUnbinder(width.checkSelfSimulate(view).modifyValue().catchObject(view) { v, a in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            v.frame.size.height = max(0, a)
        }, for: #function)
        return self
    }

    @discardableResult
    func top(_ top: ValueModifiable) -> Self {
        view.py_setUnbinder(top.modifyValue().catchObject(view) { v, a in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            var f = v.frame
            f.origin.y = a
            f.size.height = max(0, v.frame.maxY - a)
            v.frame = f
        }, for: #function)
        return self
    }

    @discardableResult
    func left(_ left: ValueModifiable) -> Self {
        view.py_setUnbinder(left.modifyValue().catchObject(view) { v, a in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            var f = v.frame
            f.origin.x = a
            f.size.width = max(0, v.frame.maxX - a)
            v.frame = f
        }, for: #function)
        return self
    }

    @discardableResult
    func bottom(_ bottom: ValueModifiable) -> Self {
        view.py_setUnbinder(bottom.modifyValue().catchObject(view) { v, a in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            var f = v.frame
            f.size.height = max(0, a - v.frame.origin.y)
            v.frame = f
        }, for: #function)
        return self
    }

    @discardableResult
    func right(_ right: ValueModifiable) -> Self {
        view.py_setUnbinder(right.modifyValue().catchObject(view) { v, a in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            var f = v.frame
            f.size.width = max(0, a - v.frame.origin.x)
            v.frame = f
        }, for: #function)
        return self
    }

    @discardableResult
    func onTap<Object: AnyObject>(to object: Object?, _ action: @escaping (Object, UITapGestureRecognizer) -> Void) -> Self {
        view.py_setUnbinder(view.py_setTap(action: { [weak object] tap in
            if let o = object {
                action(o, tap)
            }
        }), for: UUID().description)
        return self
    }

    @discardableResult
    func onTap<C: WeakCatchable, O>(to catcher: C, _ action: @escaping (O, UITapGestureRecognizer) -> Void) -> Self where C.Object == O {
        onTap(to: catcher.catchedWeakObject, action)
    }

    @discardableResult
    func onTap(_ action: @escaping (UITapGestureRecognizer) -> Void) -> Self {
        view.py_setUnbinder(view.py_setTap(action: { tap in
            action(tap)
        }), for: UUID().description)
        return self
    }

    @discardableResult
    func onTap(_ action: @escaping () -> Void) -> Self {
        view.py_setUnbinder(view.py_setTap(action: { _ in
            action()
        }), for: UUID().description)
        return self
    }

    @discardableResult
    func tag(_ tag: Int) -> Self {
        view.tag = tag
        return self
    }

    @discardableResult
    func styleSheet<O: Outputing>(_ styles: O) -> Self where O.OutputType: StyleSheet {
        styles.safeBind(to: view, id: "\(#function)") { v, s in
            v.py_styleSheet = s
        }
        return self
    }

    @discardableResult
    func styleSheet(_ sheet: StyleSheet) -> Self {
        view.py_styleSheet = sheet
        return self
    }

    @discardableResult
    func styles(_ styles: [Style]) -> Self {
        return styleSheet(StyleSheet(styles: styles))
    }

    @discardableResult
    func style(_ style: Style) -> Self {
        return styles([style])
    }
}

extension UIView {
    public func py_setTap(action: @escaping (UITapGestureRecognizer) -> Void) -> Unbinder {
        let tap = UITapGestureRecognizer()
        let unbinder = tap.py_addAction { g in
            action(g as! UITapGestureRecognizer)
        }
        addGestureRecognizer(tap)
        py_setUnbinder(unbinder, for: #function)
        return unbinder
    }
}
