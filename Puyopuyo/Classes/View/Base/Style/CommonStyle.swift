//
//  CommonStyle.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/28.
//

import Foundation

// MARK: - extensions
extension Styles {
    public static var blackBg: Style {
        return UIViewValueStyle<UIColor?>(value: .black, keyPath: \UIView.backgroundColor)
    }
    public static var whiteBg: Style {
        return UIViewValueStyle<UIColor?>(value: .white, keyPath: \UIView.backgroundColor)
    }
    public static func bgColor(_ value: UIColor?) -> Style {
        return UIViewValueStyle<UIColor?>(value: value, keyPath: \UIView.backgroundColor)
    }
    public static func borderWidth(_ value: CGFloat) -> Style {
        return UIViewValueStyle<CGFloat>(value: value, keyPath: \UIView.layer.borderWidth)
    }
    public static func borderColor(_ value: CGColor?) -> Style {
        return UIViewValueStyle<CGColor?>(value: value, keyPath: \UIView.layer.borderColor)
    }
    public static func cornerRadius(_ value: CGFloat) -> Style {
        return UIViewValueStyle<CGFloat>(value: value, keyPath: \UIView.layer.cornerRadius)
    }
    public static func clipToBounds(_ value: Bool) -> Style {
        return UIViewValueStyle<Bool>(value: value, keyPath: \UIView.clipsToBounds)
    }
    public static func userInterctionEnabled(_ value: Bool) -> Style {
        return UIViewValueStyle<Bool>(value: value, keyPath: \UIView.isUserInteractionEnabled)
    }
}
