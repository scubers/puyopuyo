//
//  PuyoHelper.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/23.
//

import Foundation

class PuyoHelper
{
    static func margin(for measure: Measure,
                       all: CGFloat? = nil,
                       horz: CGFloat? = nil,
                       vert: CGFloat? = nil,
                       top: CGFloat? = nil,
                       left: CGFloat? = nil,
                       bottom: CGFloat? = nil,
                       right: CGFloat? = nil)
    {
        if let all = all
        {
            measure.margin = UIEdgeInsets(top: all, left: all, bottom: all, right: all)
        }
        if let horz = horz
        {
            measure.margin.left = horz
            measure.margin.right = horz
        }
        if let vert = vert
        {
            measure.margin.top = vert
            measure.margin.bottom = vert
        }
        if let top = top { measure.margin.top = top }
        if let left = left { measure.margin.left = left }
        if let bottom = bottom { measure.margin.bottom = bottom }
        if let right = right { measure.margin.right = right }
    }

    static func padding(for regulator: Regulator,
                        all: CGFloat? = nil,
                        horz: CGFloat? = nil,
                        vert: CGFloat? = nil,
                        top: CGFloat? = nil,
                        left: CGFloat? = nil,
                        bottom: CGFloat? = nil,
                        right: CGFloat? = nil)
    {
        if let all = all
        {
            regulator.padding = UIEdgeInsets(top: all, left: all, bottom: all, right: all)
        }
        if let horz = horz
        {
            regulator.padding.left = horz
            regulator.padding.right = horz
        }
        if let vert = vert
        {
            regulator.padding.top = vert
            regulator.padding.bottom = vert
        }
        if let top = top { regulator.padding.top = top }
        if let left = left { regulator.padding.left = left }
        if let bottom = bottom { regulator.padding.bottom = bottom }
        if let right = right { regulator.padding.right = right }
    }
}
