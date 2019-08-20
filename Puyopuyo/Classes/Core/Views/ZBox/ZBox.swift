//
//  ZBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

open class ZBox: BoxView {
    
    @discardableResult
    public static func attach(_ parent: UIView? = nil, _ block: PuyoLinkBlock? = nil) -> PuyoLink<ZBox> {
        return ZBox().attach(parent, block)
    }
    
    public override var layout: ZLayout {
        return py_measure as! ZLayout
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        new()
    }
    
    private func new() {
        let parentMeasure = superview?.py_measure ?? Measure()
        let parentCGSize = superview?.bounds.size ?? .zero
        
        // 本身固有尺寸
        _selfSizeAdapting(size: layout.size)
        
        // 旧尺寸
        let oldSize = bounds.size
        // 计算后尺寸不可能为包裹
        let sizeAfterCaculate = layout.caculate(byParent: parentMeasure)
        // 应用计算后的固有尺寸
        _selfSizeAdapting(size: sizeAfterCaculate)
        
        if superview is BoxView {
            // 父视图为布局
        } else {
            // 父视图为普通视图
            let fixedSize = Caculator.caculate(size: sizeAfterCaculate, by: parentCGSize)
            let newSize = CGSize(width: fixedSize.width.fixedValue, height: fixedSize.height.fixedValue)
            bounds.size = newSize
            center = CGPoint(x: bounds.midX, y: bounds.midY)
        }
        
        if oldSize != bounds.size {
            _ = layout.caculate(byParent: parentMeasure)
        }

    }
}
