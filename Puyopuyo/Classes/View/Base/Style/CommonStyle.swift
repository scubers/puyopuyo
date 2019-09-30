//
//  CommonStyle.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/28.
//

import Foundation

// MARK: - extensions
extension Styles {
    @objc public static var blackBg: Style {
        return UIViewStyle(value: .black, keyPath: \UIView.backgroundColor)
    }
    @objc public static var whiteBg: Style {
        return UIViewStyle(value: .white, keyPath: \UIView.backgroundColor)
    }
    @objc public static func bgColor(_ value: UIColor?) -> Style {
        return UIViewStyle(value: value, keyPath: \UIView.backgroundColor)
    }
    @objc public static func borderWidth(_ value: CGFloat) -> Style {
        return UIViewStyle(value: value, keyPath: \UIView.layer.borderWidth)
    }
    @objc public static func borderColor(_ value: CGColor?) -> Style {
        return UIViewStyle(value: value, keyPath: \UIView.layer.borderColor)
    }
    @objc public static func cornerRadius(_ value: CGFloat) -> Style {
        return UIViewStyle(value: value, keyPath: \UIView.layer.cornerRadius)
    }
    @objc public static func clipToBounds(_ value: Bool) -> Style {
        return UIViewStyle(value: value, keyPath: \UIView.clipsToBounds)
    }
    @objc public static func userInterctionEnabled(_ value: Bool) -> Style {
        return UIViewStyle(value: value, keyPath: \UIView.isUserInteractionEnabled)
    }
    @objc public static func frame(_ frame: CGRect) -> Style {
        return UIViewStyle(value: frame, keyPath: \UIView.frame)
    }
    @objc public static func bounds(_ value: CGRect) -> Style {
        return UIViewStyle(value: value, keyPath: \UIView.bounds)
    }
    @objc public static func center(_ value: CGPoint) -> Style {
        return UIViewStyle(value: value, keyPath: \UIView.center)
    }
}
