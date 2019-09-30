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
public struct Styles {
}

final public class StyleSheet: Outputing {
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

extension Styleable {
    public func applyStyles(_ styles: [Style]) {
        styles.forEach({
            $0.apply(to: self)
        })
    }
}

extension UIView {
//    @objc public func py_applyStyleSheets(_ styleSheets: [StyleSheet]) {
//        styleSheets.forEach({ self.applyStyles($0.styles) })
//    }
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
