//
//  PuyoHelper.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/23.
//

import Foundation

open class PuyoHelper {
    
    open class func size(for view: UIView, width: SizeDescription?, height: SizeDescription?) {
        if let width = width { view.py_measure.size.width = width }
        if let height = height { view.py_measure.size.height = height }
        setNeedsLayout(view)
    }
    
    open class func margin(for view: UIView, all: CGFloat? = nil, top: CGFloat? = nil, left: CGFloat? = nil, bottom: CGFloat? = nil, right: CGFloat? = nil) {
        if let all = all {
            view.py_measure.margin = UIEdgeInsets(top: all, left: all, bottom: all, right: all)
        }
        if let top = top { view.py_measure.margin.top = top }
        if let left = left { view.py_measure.margin.left = left }
        if let bottom = bottom { view.py_measure.margin.bottom = bottom }
        if let right = right { view.py_measure.margin.right = right }
        setNeedsLayout(view)
    }
    
    open class func aligment(for view: UIView, aligment: Aligment) {
        view.py_measure.aligment = aligment
        setNeedsLayout(view)
    }
    
    open class func activated(for view: UIView, activated: Bool) {
        view.py_measure.activated = activated
        setNeedsLayout(view)
    }
    
    public class func setNeedsLayout(_ view: UIView) {
        view.py_setNeedsLayout()
    }
}
