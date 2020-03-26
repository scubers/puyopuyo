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

    open class func margin(for view: UIView,
                           all: CGFloat? = nil,
                           horz: CGFloat? = nil,
                           vert: CGFloat? = nil,
                           top: CGFloat? = nil,
                           left: CGFloat? = nil,
                           bottom: CGFloat? = nil,
                           right: CGFloat? = nil) {
        if let all = all {
            view.py_measure.margin = UIEdgeInsets(top: all, left: all, bottom: all, right: all)
        }
        if let horz = horz {
            view.py_measure.margin.left = horz
            view.py_measure.margin.right = horz
        }
        if let vert = vert {
            view.py_measure.margin.top = vert
            view.py_measure.margin.bottom = vert
        }
        if let top = top { view.py_measure.margin.top = top }
        if let left = left { view.py_measure.margin.left = left }
        if let bottom = bottom { view.py_measure.margin.bottom = bottom }
        if let right = right { view.py_measure.margin.right = right }
        setNeedsLayout(view)
    }

    open class func padding<T: Boxable>(for view: T,
                                        all: CGFloat? = nil,
                                        horz: CGFloat? = nil,
                                        vert: CGFloat? = nil,
                                        top: CGFloat? = nil,
                                        left: CGFloat? = nil,
                                        bottom: CGFloat? = nil,
                                        right: CGFloat? = nil) {
        if let all = all {
            view.regulator.padding = UIEdgeInsets(top: all, left: all, bottom: all, right: all)
        }
        if let horz = horz {
            view.regulator.padding.left = horz
            view.regulator.padding.right = horz
        }
        if let vert = vert {
            view.regulator.padding.top = vert
            view.regulator.padding.bottom = vert
        }
        if let top = top { view.regulator.padding.top = top }
        if let left = left { view.regulator.padding.left = left }
        if let bottom = bottom { view.regulator.padding.bottom = bottom }
        if let right = right { view.regulator.padding.right = right }
        if let view = view as? UIView {
            setNeedsLayout(view)
        }
    }

    open class func alignment(for view: UIView, alignment: Alignment) {
        view.py_measure.alignment = alignment
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
