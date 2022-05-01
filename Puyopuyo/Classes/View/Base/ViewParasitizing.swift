//
//  ViewParasitizing.swift
//  Puyopuyo
//
//  Created by ByteDance on 2022/5/1.
//

import Foundation

public protocol ViewDisplayable: AnyObject {
    var dislplayView: UIView { get }
}

/// Describe an object that can be add view to it
public protocol ViewParasitizing: AnyObject {
    func addParasite(_ parasite: ViewDisplayable)
    func removeParasite(_ parasite: ViewDisplayable)
    func setNeedsLayout()
}

// MARK: - ViewParasitizing extension

public extension ViewDisplayable where Self: UIView {
    var dislplayView: UIView { self }
}

public extension ViewDisplayable where Self: UIViewController {
    var dislplayView: UIView { view }
}

// MARK: - Default Impls

extension UIView: ViewDisplayable {}

extension UIViewController: ViewDisplayable {}
