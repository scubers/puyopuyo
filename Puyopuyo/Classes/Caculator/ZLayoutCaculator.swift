//
//  ZLayoutCaculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

class ZLayoutCaculator {
    static func caculate(layout: ZLayout, parent: Measure) -> Size {
        
        let layoutFixedSize = layout.target?.py_size ?? .zero
        
        let children = layout.children.filter({ $0.activated })
        
        var maxSizeWithMargin = CGSize.zero
        
        for (measure) in children {
            
            let subSize = measure.caculate(byParent: layout)
            let subMargin = measure.margin
            
            if subSize.width.isWrap || subSize.height.isWrap {
                fatalError()
            }
            
            // 计算大小
            let sizeAfterCaculate = Caculator.caculate(size: subSize, by: layoutFixedSize)
            measure.target?.py_size = CGSize(width: sizeAfterCaculate.width.fixedValue, height: sizeAfterCaculate.height.fixedValue)
            maxSizeWithMargin.width = max(maxSizeWithMargin.width, sizeAfterCaculate.width.fixedValue + subMargin.left + subMargin.right)
            maxSizeWithMargin.height = max(maxSizeWithMargin.height, sizeAfterCaculate.height.fixedValue + subMargin.top + subMargin.bottom)
            
            // 计算中心
            var center = CGPoint(x: layoutFixedSize.width / 2, y: layoutFixedSize.height / 2)
            let aligment = measure.aligment.contains(.none) ? layout.crossAxis : measure.aligment
            checkAligmentAvailable(aligment)
            
            if aligment.contains(.left) {
                center.x = layout.padding.left + subMargin.left + sizeAfterCaculate.width.fixedValue / 2
            } else if aligment.contains(.right) {
                center.x = layoutFixedSize.width - (layout.padding.right + subMargin.right + sizeAfterCaculate.width.fixedValue / 2)
            }
            
            if aligment.contains(.top) {
                center.y = layout.padding.top + subMargin.top + sizeAfterCaculate.height.fixedValue / 2
            } else if aligment.contains(.bottom) {
                center.y = layoutFixedSize.height - (layout.padding.bottom + subMargin.bottom + sizeAfterCaculate.height.fixedValue / 2)
            }
            
            measure.target?.py_center = center
        }
        
        // 计算布局自身大小
        var width = layout.size.width
        if width.isWrap {
            width = .fixed(maxSizeWithMargin.width + layout.padding.left + layout.padding.right)
        }
        
        var height = layout.size.height
        if height.isWrap {
            height = .fixed(maxSizeWithMargin.height + layout.padding.top + layout.padding.bottom)
        }
        
        return Size(width: width, height: height)
    }
    
    private static func checkAligmentAvailable(_ aligment: Aligment) {
        if aligment.contains([.left, .right]) {
            fatalError("不能同时设置左右")
        }
        if aligment.contains([.top, .bottom]) {
            fatalError("不能同时设置左右")
        }
    }
}
