//
//  PuyoLinkHelper.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/23.
//

import Foundation

open class PuyoLinkHelper {
    
    open class func size(for view: UIView, width: SizeType?, height: SizeType?) {
        if let width = width { view.py_measure.unit.size.width = width }
        if let height = height { view.py_measure.unit.size.height = height }
    }
    /*
    
    open class func size(for view: UIView, width: Sizable?, height: Sizable?, direction: Direction) {
        if direction == .x {
            if let width = width { view.py_measure.size.main = width }
            if let height = height { view.py_measure.size.cross = height }
        } else {
            if let height = height { view.py_measure.size.main = height }
            if let width = width { view.py_measure.size.cross = width }
        }
    }
    */
    
    open class func margin(for view: UIView, all: CGFloat? = nil, top: CGFloat? = nil, left: CGFloat? = nil, bottom: CGFloat? = nil, right: CGFloat? = nil, direction: Direction) {
        if let all = all {
            view.py_measure.margin = Edges(start: all, end: all, forward: all, backward: all)
        }
        if direction == .x {
            if let top = top { view.py_measure.margin.backward = top }
            if let left = left { view.py_measure.margin.start = (left) }
            if let bottom = bottom { view.py_measure.margin.forward = (bottom) }
            if let right = right { view.py_measure.margin.end = (right) }
        } else {
            if let top = top { view.py_measure.margin.start = top }
            if let left = left { view.py_measure.margin.forward = (left) }
            if let bottom = bottom { view.py_measure.margin.end = (bottom) }
            if let right = right { view.py_measure.margin.backward = (right) }
        }
    }
    
    open class func visibility(for view: UIView, visibility: Visiblity) {
        switch visibility {
        case .gone:
            view.isHidden = true
            view.py_measure.activated = false
        case .invisible:
            view.isHidden = true
            view.py_measure.activated = true
        case .visible:
            view.isHidden = false
            view.py_measure.activated = true
        }
    }
    
    open class func vAligment(for view: UIView, aligment: VAligment) {
        if case .center = aligment {
            view.py_measure.aligment = .center
        } else {
            view.py_measure.aligment = aligment == .top ? .backward : .forward
        }
    }
    
    open class func hAligment(for view: UIView, aligment: HAligment) {
        if case .center = aligment {
            view.py_measure.aligment = .center
        } else {
            view.py_measure.aligment = aligment == .right ? .backward : .forward
        }
    }
}
