//
//  ZBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

open class ZBox: BoxView {
    
    @discardableResult
    public static func attach(_ parent: UIView? = nil, wrap: Bool = true, _ block: PuyoLinkBlock? = nil) -> PuyoLink<ZBox> {
        return ZBox().attach(parent, wrap: wrap, block)
    }
    
    public override var layout: ZLayout {
        return py_measure as! ZLayout
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if layout.size.isFixed() {
            bounds.size = CGSize(width: layout.size.width.fixedValue, height: layout.size.height.fixedValue)
        }
        
        let oldSize = bounds.size
        
        let parentMeasure = superview?.py_measure ?? Measure()
        
        let sizeAfterCaculate = layout.caculate(byParent: parentMeasure)
        
        if superview is BoxView  {
            // 父视图为布局视图
            // 通过计算如果已经确定了尺寸，也可以直接设置
            if sizeAfterCaculate.isFixed() {
                bounds.size = CGSize(width: sizeAfterCaculate.width.fixedValue, height: sizeAfterCaculate.height.fixedValue)
            }
            if oldSize != bounds.size {
                _ = layout.caculate(byParent: parentMeasure)
            }

        } else {
            // 父视图为非布局视图
            let parentCGSize = superview?.bounds ?? .zero
            
            let fixedSize = Caculator.caculate(size: sizeAfterCaculate, by: parentCGSize.size)
            let newSize = CGSize(width: fixedSize.width.fixedValue, height: fixedSize.height.fixedValue)
            
            bounds.size = newSize
            
            if oldSize != newSize {
                _ = layout.caculate(byParent: parentMeasure)
            }
            
            center = CGPoint(x: bounds.midX, y: bounds.midY)
        }
    }
    
}
