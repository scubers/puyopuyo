//
//  Puyo+UIView.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/1.
//

import Foundation

public extension Puyo where T: DisposableBag {
    @discardableResult
    func keyPath<S: Outputing>(_ keyPath: ReferenceWritableKeyPath<T, S.OutputType>, _ output: S) -> Self {
        output.safeBind(to: view, id: "\(#function) | \(type(of: keyPath))") { v, a in
            v[keyPath: keyPath] = a
        }
        return self
    }
}

public extension Puyo where T: UIView {
    @discardableResult
    func backgroundColor<S: Outputing>(_ color: S) -> Self where S.OutputType: OptionalableValueType, S.OutputType.Wrap == UIColor {
        keyPath(\.backgroundColor, color.mapTo(\.optionalValue))
    }

    @discardableResult
    func contentMode<S: Outputing>(_ mode: S) -> Self where S.OutputType == UIView.ContentMode {
        keyPath(\.contentMode, mode)
    }

    @discardableResult
    func contentMode(_ mode: UIView.ContentMode) -> Self {
        view.contentMode = mode
        return self
    }

    @discardableResult
    func clipToBounds<S: Outputing>(_ clip: S) -> Self where S.OutputType == Bool {
        keyPath(\T.clipsToBounds, clip)
    }

    @discardableResult
    func cornerRadius<S: Outputing>(_ radius: S) -> Self where S.OutputType: CGFloatable {
        keyPath(\T.layer.cornerRadius, radius.mapTo(\.cgFloatValue))
            .clipToBounds(true)
    }

    @discardableResult
    func borderWidth<S: Outputing>(_ width: S) -> Self where S.OutputType: CGFloatable {
        keyPath(\T.layer.borderWidth, width.mapTo(\.cgFloatValue))
    }

    @discardableResult
    func borderColor<S: Outputing>(_ color: S) -> Self where S.OutputType: OptionalableValueType, S.OutputType.Wrap == UIColor {
        keyPath(\T.layer.borderColor, color.mapTo(\.optionalValue).map(\.?.cgColor))
    }

    @discardableResult
    func alpha<S: Outputing>(_ alpha: S) -> Self where S.OutputType == CGFloat {
        keyPath(\T.alpha, alpha)
    }

    @discardableResult
    func userInteractionEnabled<S: Outputing>(_ enabled: S) -> Self where S.OutputType == Bool {
        keyPath(\T.isUserInteractionEnabled, enabled)
    }

    @discardableResult
    func frame<S: Outputing>(_ frame: S) -> Self where S.OutputType == CGRect {
        keyPath(\T.frame, frame)
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
        frame.safeBind(to: view, id: #function) { v, a in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            v.bounds = a
        }.unbind(by: view)
        return self
    }

    @discardableResult
    func center<S: Outputing>(_ point: S) -> Self where S.OutputType == CGPoint {
        keyPath(\T.center, point)
    }

    @discardableResult
    func onBoundsChanged<O: Inputing>(_ bounds: O) -> Self where O.InputType == CGRect {
        view.py_boundsState().send(to: bounds).unbind(by: view)
        return self
    }

    @discardableResult
    func onCenterChanged<O: Inputing>(_ center: O) -> Self where O.InputType == CGPoint {
        view.py_centerState().send(to: center).unbind(by: view)
        return self
    }

    @discardableResult
    func onFrameChanged<O: Inputing>(_ frame: O) -> Self where O.InputType == CGRect {
        view.py_frameStateByBoundsCenter().send(to: frame).unbind(by: view)
        view.py_frameStateByKVO().send(to: frame).unbind(by: view)
        return self
    }

    @discardableResult
    func frameX(_ x: ValueModifiable) -> Self {
        view.addDisposable(x.checkSelfSimulate(view).modifyValue().catchObject(view) { v, a in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            v.frame.origin.x = a
        }, for: #function)
        return self
    }

    @discardableResult
    func frameY(_ y: ValueModifiable) -> Self {
        view.addDisposable(y.checkSelfSimulate(view).modifyValue().catchObject(view) { v, a in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            v.frame.origin.y = a
        }, for: #function)
        return self
    }

    @discardableResult
    func frameWidth(_ width: ValueModifiable) -> Self {
        view.addDisposable(width.checkSelfSimulate(view).modifyValue().catchObject(view) { v, a in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            v.frame.size.width = max(0, a)
        }, for: #function)
        return self
    }

    @discardableResult
    func frameHeight(_ width: ValueModifiable) -> Self {
        view.addDisposable(width.checkSelfSimulate(view).modifyValue().catchObject(view) { v, a in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            v.frame.size.height = max(0, a)
        }, for: #function)
        return self
    }

    @discardableResult
    func top(_ top: ValueModifiable) -> Self {
        view.addDisposable(top.modifyValue().catchObject(view) { v, a in
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
        view.addDisposable(left.modifyValue().catchObject(view) { v, a in
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
        view.addDisposable(bottom.modifyValue().catchObject(view) { v, a in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            var f = v.frame
            f.size.height = max(0, a - v.frame.origin.y)
            v.frame = f
        }, for: #function)
        return self
    }

    @discardableResult
    func right(_ right: ValueModifiable) -> Self {
        view.addDisposable(right.modifyValue().catchObject(view) { v, a in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            var f = v.frame
            f.size.width = max(0, a - v.frame.origin.x)
            v.frame = f
        }, for: #function)
        return self
    }

    @discardableResult
    func onTap<Object: AnyObject>(to object: Object?, _ action: @escaping (Object, UITapGestureRecognizer) -> Void) -> Self {
        view.addDisposable(view.py_setTap(action: { [weak object] tap in
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
        view.addDisposable(view.py_setTap(action: { tap in
            action(tap)
        }), for: UUID().description)
        return self
    }

    @discardableResult
    func onTap(_ action: @escaping () -> Void) -> Self {
        view.addDisposable(view.py_setTap(action: { _ in
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

public extension UIView {
    func py_setTap(action: @escaping (UITapGestureRecognizer) -> Void) -> Disposable {
        let tap = UITapGestureRecognizer()
        let Disposable = tap.py_addAction { g in
            action(g as! UITapGestureRecognizer)
        }
        addGestureRecognizer(tap)
        addDisposable(Disposable, for: #function)
        return Disposable
    }
}
