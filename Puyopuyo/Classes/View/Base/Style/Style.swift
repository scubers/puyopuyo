//
//  Style.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/28.
//

import Foundation

@objc public protocol Style {
    func apply(to decorable: Decorable)
}

// MARK: - Conveniences

open class StyleSheet: Outputing {
    public typealias OutputType = StyleSheet
    public var styles: [Style]
    public init(styles: [Style]) {
        self.styles = styles
    }

    public func combine(sheet: StyleSheet) -> StyleSheet {
        return StyleSheet(styles: styles + sheet.styles)
    }

    public func combine(_ styles: [Style]) -> StyleSheet {
        return StyleSheet(styles: self.styles + styles)
    }
}

extension Decorable {
    public func applyStyles(_ styles: [Style]) {
        styles.forEach({ $0.apply(to: self) })
    }

    public func applyStyleSheet(_ sheet: StyleSheet) {
        applyStyles(sheet.styles)
    }
}

extension UIView {
    public var py_styleSheet: StyleSheet? {
        set {
            if let sheet = newValue {
                applyStyleSheet(sheet)
            }
            objc_setAssociatedObject(self, &Key.py_styleSheetKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &Key.py_styleSheetKey) as? StyleSheet
        }
    }

    private struct Key {
        static var py_styleSheetKey = "py_styleSheetKey"
    }
}

extension UIView: Decorable {}

// MARK: - Util

struct StyleUtil {
    static func convert<T>(_ value: Any, _: T.Type) -> T? {
        if let v = value as? T {
            return v
        }
        return nil
    }
}
