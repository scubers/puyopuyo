//
//  Puyo+UIView.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/1.
//

import Foundation

public extension Puyo where T: DisposableBag {
    @discardableResult
    func bind<S: Outputing>(keyPath: ReferenceWritableKeyPath<T, S.OutputType>, _ output: S) -> Self {
        output.safeBind(to: view) {
            $0[keyPath: keyPath] = $1
        }
        return self
    }

    @discardableResult
    func bind<R>(keyPath: ReferenceWritableKeyPath<T, R>, _ value: R) -> Self {
        view[keyPath: keyPath] = value
        return self
    }
}

public extension Puyo where T: UIView {
    @discardableResult
    func backgroundColor<S: Outputing>(_ color: S) -> Self where S.OutputType: OptionalableValueType, S.OutputType.Wrap == UIColor {
        bind(keyPath: \.backgroundColor, color.asOutput().map(\.optionalValue))
    }

    @discardableResult
    func backgroundColor(_ color: UIColor?) -> Self {
        bind(keyPath: \.backgroundColor, color)
    }

    @discardableResult
    func contentMode<S: Outputing>(_ mode: S) -> Self where S.OutputType == UIView.ContentMode {
        bind(keyPath: \.contentMode, mode)
    }

    @discardableResult
    func contentMode(_ mode: UIView.ContentMode) -> Self {
        bind(keyPath: \.contentMode, mode)
    }

    @discardableResult
    func clipToBounds<S: Outputing>(_ clip: S) -> Self where S.OutputType == Bool {
        bind(keyPath: \T.clipsToBounds, clip)
    }

    @discardableResult
    func cornerRadius<S: Outputing>(_ radius: S) -> Self where S.OutputType: CGFloatable {
        bind(keyPath: \T.layer.cornerRadius, radius.asOutput().map(\.cgFloatValue))
            .clipToBounds(true)
    }

    @discardableResult
    func borderWidth<S: Outputing>(_ width: S) -> Self where S.OutputType: CGFloatable {
        bind(keyPath: \T.layer.borderWidth, width.asOutput().map(\.cgFloatValue))
    }

    @discardableResult
    func borderColor<S: Outputing>(_ color: S) -> Self where S.OutputType: OptionalableValueType, S.OutputType.Wrap == UIColor {
        bind(keyPath: \T.layer.borderColor, color.asOutput().map(\.optionalValue).map(\.?.cgColor))
    }

    @discardableResult
    func alpha<S: Outputing>(_ alpha: S) -> Self where S.OutputType == CGFloat {
        bind(keyPath: \T.alpha, alpha)
    }

    @discardableResult
    func userInteractionEnabled<S: Outputing>(_ enabled: S) -> Self where S.OutputType == Bool {
        bind(keyPath: \T.isUserInteractionEnabled, enabled)
    }

    @discardableResult
    func frame<S: Outputing>(_ frame: S) -> Self where S.OutputType == CGRect {
        bind(keyPath: \T.frame, frame)
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
        frame.safeBind(to: view) { v, a in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            v.bounds = a
        }.dispose(by: view)
        return self
    }

    @discardableResult
    func center<S: Outputing>(_ point: S) -> Self where S.OutputType == CGPoint {
        bind(keyPath: \T.center, point)
    }

    @discardableResult
    func onBoundsChanged<O: Inputing>(_ bounds: O) -> Self where O.InputType == CGRect {
        view.py_boundsState().send(to: bounds).dispose(by: view)
        return self
    }

    @discardableResult
    func onCenterChanged<O: Inputing>(_ center: O) -> Self where O.InputType == CGPoint {
        view.py_centerState().send(to: center).dispose(by: view)
        return self
    }

    @discardableResult
    func onFrameChanged<O: Inputing>(_ frame: O) -> Self where O.InputType == CGRect {
        view.py_frameState().send(to: frame).dispose(by: view)
        return self
    }

    @discardableResult
    func top<O: Outputing>(_ top: O) -> Self where O.OutputType: CGFloatable {
        top.safeBind(to: view) { v, a in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            var f = v.frame
            f.origin.y = a.cgFloatValue
            f.size.height = max(0, v.frame.maxY - a.cgFloatValue)
            v.frame = f
        }
        return self
    }

    @discardableResult
    func left<O: Outputing>(_ left: O) -> Self where O.OutputType: CGFloatable {
        left.safeBind(to: view) { v, a in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            var f = v.frame
            f.origin.x = a.cgFloatValue
            f.size.width = max(0, v.frame.maxX - a.cgFloatValue)
            v.frame = f
        }
        return self
    }

    @discardableResult
    func bottom<O: Outputing>(_ bottom: O) -> Self where O.OutputType: CGFloatable {
        bottom.safeBind(to: view) { v, a in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            var f = v.frame
            f.size.height = max(0, a.cgFloatValue - v.frame.origin.y)
            v.frame = f
        }
        return self
    }

    @discardableResult
    func right<O: Outputing>(_ right: O) -> Self where O.OutputType: CGFloatable {
        right.safeBind(to: view) { v, a in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            var f = v.frame
            f.size.width = max(0, a.cgFloatValue - v.frame.origin.x)
            v.frame = f
        }
        return self
    }

    @discardableResult
    func onTap<Object: AnyObject>(to object: Object?, _ action: @escaping (Object, UITapGestureRecognizer) -> Void) -> Self {
        onTap { [weak object] tap in
            if let o = object {
                action(o, tap)
            }
        }
    }

    @discardableResult
    func onTap(_ action: @escaping (UITapGestureRecognizer) -> Void) -> Self {
        onTap(Inputs(action))
    }

    @discardableResult
    func onTap(_ action: @escaping () -> Void) -> Self {
        onTap(Inputs { _ in
            action()
        })
    }

    @discardableResult
    func onTap<I: Inputing>(_ input: I) -> Self where I.InputType == UITapGestureRecognizer {
        view.py_addTap(action: {
            input.input(value: $0)
        })
        return self
    }

    @discardableResult
    func tag(_ tag: Int) -> Self {
        view.tag = tag
        return self
    }

    @discardableResult
    func styleSheet<O: Outputing>(_ styles: O) -> Self where O.OutputType: StyleSheet {
        styles.safeBind(to: view) { v, s in
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
