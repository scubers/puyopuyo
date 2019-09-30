//
//  CommonStyle.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/28.
//

import Foundation

// MARK: - extensions
extension Styles {
    @objc public static var blackBg: Styles {
        return Styles(style: UIViewValueStyle<UIColor?>(value: .black, keyPath: \UIView.backgroundColor))
    }
    @objc public static var whiteBg: Styles {
        return Styles(style: UIViewValueStyle<UIColor?>(value: .white, keyPath: \UIView.backgroundColor))
    }
    @objc public static func bgColor(_ value: UIColor?) -> Styles {
        return Styles(style: UIViewValueStyle<UIColor?>(value: value, keyPath: \UIView.backgroundColor))
    }
    @objc public static func borderWidth(_ value: CGFloat) -> Styles {
        return Styles(style: UIViewValueStyle<CGFloat>(value: value, keyPath: \UIView.layer.borderWidth))
    }
    @objc public static func borderColor(_ value: CGColor?) -> Styles {
        return Styles(style: UIViewValueStyle<CGColor?>(value: value, keyPath: \UIView.layer.borderColor))
    }
    @objc public static func cornerRadius(_ value: CGFloat) -> Styles {
        return Styles(style: UIViewValueStyle<CGFloat>(value: value, keyPath: \UIView.layer.cornerRadius))
    }
    @objc public static func clipToBounds(_ value: Bool) -> Styles {
        return Styles(style: UIViewValueStyle<Bool>(value: value, keyPath: \UIView.clipsToBounds))
    }
    @objc public static func userInterctionEnabled(_ value: Bool) -> Styles {
        return Styles(style: UIViewValueStyle<Bool>(value: value, keyPath: \UIView.isUserInteractionEnabled))
    }
}
