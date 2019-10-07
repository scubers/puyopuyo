//
//  Style.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/28.
//

import Foundation

// MARK: - Declare
@objc public protocol Decorable {
}

@objc public protocol Style {
    func apply(to decorable: Decorable)
}

@objc public protocol UIControlStatable {
    var controlState: UIControl.State { get }
}

// MARK: - Conveniences

open class StyleSheet: Outputing {
    public typealias OutputType = StyleSheet
    public var styles: [Style]
    @objc public init(styles: [Style]) {
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
        static var py_selectedStyleSheetKey = "py_selectedStyleSheetKey"
        static var py_selectedKey = "py_selectedKey"
    }
    /*
    
    public var py_currentStyleSheet: StyleSheet? {
        return py_styleSelected ? py_selectedStyleSheet : py_styleSheet
    }
    
    public func py_setStyleSheet(_ sheet: StyleSheet?, selected: Bool = false) {
        if selected {
            py_selectedStyleSheet = sheet
        } else {
            py_styleSheet = sheet
        }
    }
    
    public var py_selectedStyleSheet: StyleSheet? {
        set {
            if py_styleSelected, let sheet = newValue {
                applyStyleSheet(sheet)
            }
            objc_setAssociatedObject(self, &Key.py_selectedStyleSheetKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &Key.py_selectedStyleSheetKey) as? StyleSheet
        }
    }
    
    public var py_styleSelected: Bool {
        set {
            if newValue {
                if let sheet = py_selectedStyleSheet {
                    applyStyleSheet(sheet)
                }
            } else {
                if let sheet = py_styleSheet {
                    applyStyleSheet(sheet)
                }
            }
            objc_setAssociatedObject(self, &Key.py_selectedKey, NSNumber(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &Key.py_selectedKey) as? NSNumber)?.boolValue ?? false
        }
    }
    */
}

extension UIView: Decorable {
}
// MARK: - Util
struct StyleUtil {
    static func convert<T>(_ value: Any, _ type: T.Type) -> T? {
        if let v = value as? T {
            return v
        }
        return nil
    }
}
