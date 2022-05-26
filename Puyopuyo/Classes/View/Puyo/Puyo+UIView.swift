//
//  Puyo+UIView.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/1.
//

import Foundation

public extension Puyo where T: UIView {
    /// Set diagnosis id, system will print the view's info in every calculate cycle
    @discardableResult
    func diagnosis(_ id: String? = "") -> Self {
        set(\T.layoutMeasure.diagnosisId, id)
    }

    /// Set extra diagnosis message
    @discardableResult
    func diagnosisMessage(_ msg: String?) -> Self {
        set(\T.layoutMeasure.extraDiagnosisMessage, msg)
    }

    @discardableResult
    func backgroundColor<O: Outputing>(_ color: O) -> Self where O.OutputType: OptionalableValueType, O.OutputType.Wrap == UIColor {
        set(\.backgroundColor, color.asOutput().map(\.optionalValue))
    }

    @discardableResult
    func backgroundColor(_ color: UIColor?) -> Self {
        set(\.backgroundColor, color)
    }

    @discardableResult
    func contentMode<O: Outputing>(_ mode: O) -> Self where O.OutputType == UIView.ContentMode {
        set(\.contentMode, mode)
    }

    @discardableResult
    func contentMode(_ mode: UIView.ContentMode) -> Self {
        set(\.contentMode, mode)
    }

    @discardableResult
    func clipToBounds<O: Outputing>(_ clip: O) -> Self where O.OutputType == Bool {
        set(\T.clipsToBounds, clip)
    }

    @discardableResult
    func cornerRadius<O: Outputing>(_ radius: O) -> Self where O.OutputType: CGFloatable {
        set(\T.layer.cornerRadius, radius.asOutput().map(\.cgFloatValue))
            .clipToBounds(true)
    }

    @discardableResult
    func borderWidth<O: Outputing>(_ width: O) -> Self where O.OutputType: CGFloatable {
        set(\T.layer.borderWidth, width.asOutput().map(\.cgFloatValue))
    }

    @discardableResult
    func borderColor<O: Outputing>(_ color: O) -> Self where O.OutputType: OptionalableValueType, O.OutputType.Wrap == UIColor {
        set(\T.layer.borderColor, color.asOutput().map(\.optionalValue).map(\.?.cgColor))
    }

    @discardableResult
    func alpha<O: Outputing>(_ alpha: O) -> Self where O.OutputType: CGFloatable {
        set(\T.alpha, alpha.asOutput().map(\.cgFloatValue))
    }

    @discardableResult
    func userInteractionEnabled<O: Outputing>(_ enabled: O) -> Self where O.OutputType == Bool {
        set(\T.isUserInteractionEnabled, enabled)
    }

    @discardableResult
    func frame<O: Outputing>(_ frame: O) -> Self where O.OutputType == CGRect {
        set(\T.frame, frame)
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
    func top<O: Outputing>(_ top: O) -> Self where O.OutputType: CGFloatable {
        doOn(top) { v, a in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            var f = v.frame
            f.origin.y = a.cgFloatValue
            f.size.height = max(0, v.frame.maxY - a.cgFloatValue)
            v.frame = f
        }
    }

    @discardableResult
    func left<O: Outputing>(_ left: O) -> Self where O.OutputType: CGFloatable {
        doOn(left) { v, a in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            var f = v.frame
            f.origin.x = a.cgFloatValue
            f.size.width = max(0, v.frame.maxX - a.cgFloatValue)
            v.frame = f
        }
    }

    @discardableResult
    func bottom<O: Outputing>(_ bottom: O) -> Self where O.OutputType: CGFloatable {
        doOn(bottom) { v, a in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            var f = v.frame
            f.size.height = max(0, a.cgFloatValue - v.frame.origin.y)
            v.frame = f
        }
    }

    @discardableResult
    func right<O: Outputing>(_ right: O) -> Self where O.OutputType: CGFloatable {
        doOn(right) { v, a in
            Puyo.ensureInactivate(v, "can only apply when view is inactiveted!!!")
            var f = v.frame
            f.size.width = max(0, a.cgFloatValue - v.frame.origin.x)
            v.frame = f
        }
    }
}
