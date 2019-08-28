//
//  ZLayoutCaculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

class ZCaculator {
    
    let layout: ZRegulator
    let parent: Measure
    init(_ layout: ZRegulator, parent: Measure) {
        self.layout = layout
        self.parent = parent
    }
    
    lazy var layoutFixedWidth: CGFloat = self.layout.padding.left + self.layout.padding.right
    lazy var layoutFixedHeight: CGFloat = self.layout.padding.top + self.layout.padding.bottom
//    lazy var layoutCalPadding = CalEdges(insets: layout.padding, direction: layout.direction)
//    lazy var layoutCalFixedSize = CalFixedSize(cgSize: layout.target?.py_size ?? .zero, direction: layout.direction)
//    lazy var layoutCalSize = CalSize(size: layout.size, direction: layout.direction)
//    lazy var totalFixedMain: CGFloat = self.layoutCalPadding.start + self.layoutCalPadding.end
    
    func caculate() -> Size {
        
        let layoutFixedSize = layout.py_size
        
        var children = [Measure]()
        layout.enumerateChild { (_, m) in
            if m.activated {
                children.append(m)
            }
        }
        
        var maxSizeWithMargin = CGSize.zero
        
        for (measure) in children {
            
            let subSize = measure.caculate(byParent: layout)
            let subMargin = measure.margin
            
            if subSize.width.isWrap || subSize.height.isWrap {
                fatalError()
            }
            let zContainerSize = CGSize(width: max(layoutFixedSize.width - layoutFixedWidth - (subMargin.left + subMargin.right), 0),
                                        height: max(layoutFixedSize.height - layoutFixedHeight - (subMargin.top + subMargin.bottom), 0))
            // 计算大小
            let sizeAfterCaculate = Caculator.caculate(size: subSize, by: zContainerSize)
            measure.py_size = CGSize(width: sizeAfterCaculate.width.fixedValue, height: sizeAfterCaculate.height.fixedValue)
            maxSizeWithMargin.width = max(maxSizeWithMargin.width, sizeAfterCaculate.width.fixedValue + subMargin.left + subMargin.right)
            maxSizeWithMargin.height = max(maxSizeWithMargin.height, sizeAfterCaculate.height.fixedValue + subMargin.top + subMargin.bottom)
            
            // 计算中心
            var center = CGPoint(x: layoutFixedSize.width / 2, y: layoutFixedSize.height / 2)
            let aligment = measure.aligment
            let justifyContent = layout.justifyContent

            // 水平方向
            let horzAligment: Aligment = aligment.hasHorzAligment() ? aligment : justifyContent
            // 垂直方向
            let vertAligment: Aligment = aligment.hasVertAligment() ? aligment : justifyContent
            
            if horzAligment.contains(.left) {
                center.x = layout.padding.left + subMargin.left + sizeAfterCaculate.width.fixedValue / 2
            } else if horzAligment.contains(.right) {
                center.x = layoutFixedSize.width - (layout.padding.right + subMargin.right + sizeAfterCaculate.width.fixedValue / 2)
            }
            
            if vertAligment.contains(.top) {
                center.y = layout.padding.top + subMargin.top + sizeAfterCaculate.height.fixedValue / 2
            } else if vertAligment.contains(.bottom) {
                center.y = layoutFixedSize.height - (layout.padding.bottom + subMargin.bottom + sizeAfterCaculate.height.fixedValue / 2)
            }
            
            measure.py_center = center
        }
        
        // 计算布局自身大小
        var width = layout.size.width
        if width.isWrap {
            width = .fix(maxSizeWithMargin.width + layout.padding.left + layout.padding.right)
        }
        
        var height = layout.size.height
        if height.isWrap {
            height = .fix(maxSizeWithMargin.height + layout.padding.top + layout.padding.bottom)
        }
        
        return Size(width: width, height: height)
    }
    
    private func checkAligmentAvailable(_ aligment: Aligment) {
        if aligment.contains([.left, .right]) {
            fatalError("不能同时设置左右")
        }
        if aligment.contains([.top, .bottom]) {
            fatalError("不能同时设置左右")
        }
    }
}
