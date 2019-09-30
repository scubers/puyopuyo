//
//  Style.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/9/28.
//

import Foundation

// MARK: - Declare
@objc public protocol Styleable {
}

@objc public protocol Style {
    func apply(to styleable: Styleable)
}

@objc public protocol UIControlStatable {
    var controlState: UIControl.State { get }
}

// MARK: - Conveniences
@objc public class Styles: NSObject, Style {
    var style: Style?
    init(style: Style) {
        super.init()
        self.style = style
    }
    public func apply(to styleable: Styleable) {
        style?.apply(to: styleable)
    }
}

@objc public class StyleSheet: NSObject {
    public var styles: [Style]
    @objc public init(styles: [Style]) {
        self.styles = styles
        super.init()
    }
}

extension Styleable {
    public func applyStyles(_ styles: [Style]) {
        styles.forEach({
            $0.apply(to: self)
        })
    }
}

extension UIView {
    @objc public func py_applyStyleSheets(_ styleSheets: [StyleSheet]) {
        styleSheets.forEach({ self.applyStyles($0.styles) })
    }
}

extension UIView: Styleable {
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
