//
//  GestureStyle.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/30.
//

import Foundation

public protocol GestureDecorable: Decorable {
    var gestureStyleView: UIView { get }
}

public protocol GestureStyle: Style {
    func apply(to gestureStyle: GestureDecorable)
}

public protocol IdentifiableStyle {
    var styleIdentifier: String { get }
}

open class BaseGestureStyle: GestureStyle, IdentifiableStyle {
    public var styleIdentifier: String

    public init(identifier: String) {
        styleIdentifier = identifier
    }

    public func apply(to decorable: Decorable) {
        if let s = StyleUtil.convert(decorable, GestureDecorable.self) {
            apply(to: s)
        }
    }

    public func apply(to gestureDecorable: GestureDecorable) {
        let v = gestureDecorable.gestureStyleView
        _removeSpecifyGesture(view: v)
        let gesture = getGesture()
        gesture.styleIdentifier = styleIdentifier
        v.addGestureRecognizer(gesture)
    }

    private func _removeSpecifyGesture(view: UIView) {
        if let gs = view.gestureRecognizers, let target = gs.first(where: { $0.styleIdentifier == self.styleIdentifier }) {
            view.removeGestureRecognizer(target)
        }
    }

    open func getGesture() -> UIGestureRecognizer {
        fatalError("impl in subclass")
    }
}

extension UIView: GestureDecorable {
    public var gestureStyleView: UIView {
        return self
    }
}

private var gestureStyleIdentifierKey = "gestureStyleIdentifierKey"
extension UIGestureRecognizer {
    public var styleIdentifier: String? {
        set {
            objc_setAssociatedObject(self, &gestureStyleIdentifierKey, newValue as NSString?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &gestureStyleIdentifierKey) as? String
        }
    }
}

// MARK: - Delegate

public class ShouldSimulateOtherGestureDelegate: NSObject, UIGestureRecognizerDelegate, Unbinder {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view == otherGestureRecognizer.view {
            return true
        }
        return false
    }

    public func py_unbind() {}
}

// MARK: - TapGestureStyle

open class TapGestureStyle: BaseGestureStyle {
    public init(identifier: String, _ action: @escaping (UITapGestureRecognizer) -> Void) {
        super.init(identifier: identifier)
        self.action = action
    }

    var action = { (_: UITapGestureRecognizer) -> Void in }
    open override func getGesture() -> UIGestureRecognizer {
        let tap = UITapGestureRecognizer()
        tap.py_addAction { g in
            self.action(g as! UITapGestureRecognizer)
        }
        return tap
    }
}

// MARK: - LongPress

open class LongPressGestureStyle: BaseGestureStyle {
    public init(identifier: String, _ action: @escaping (UILongPressGestureRecognizer) -> Void) {
        super.init(identifier: identifier)
        self.action = action
    }

    var action = { (_: UILongPressGestureRecognizer) -> Void in }
    open override func getGesture() -> UIGestureRecognizer {
        let tap = UILongPressGestureRecognizer()
        tap.py_addAction { g in
            self.action(g as! UILongPressGestureRecognizer)
        }
        return tap
    }
}

// MARK: -

public class LayerGesture: UIGestureRecognizer {
    public var layer = CAShapeLayer()
    public var color = UIColor.lightGray.withAlphaComponent(0.6)
    public init(color: UIColor? = nil) {
        super.init(target: nil, action: nil)
        if let color = color {
            self.color = color
        }
    }
}
