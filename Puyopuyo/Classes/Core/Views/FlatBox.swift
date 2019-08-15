
//
//  File.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import Foundation

open class FlatBox: BoxView {
    
    public override var layout: FlatLayout {
        return py_measure as! FlatLayout
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
            
            // 控制父视图的scroll
            if let scrollView = superview as? UIScrollView, layout.autoJudgeScroll {
                let contentSize = scrollView.contentSize
                if layout.size.width.isWrap {
                    scrollView.contentSize.width = max(contentSize.width, newSize.width + layout.padding.left + layout.padding.right + frame.origin.x)
                }
                if layout.size.height.isWrap {
                    scrollView.contentSize.height = max(contentSize.height, newSize.height + layout.padding.bottom + layout.padding.top + frame.origin.y)
                }
            }
        }
        
        if oldSize != bounds.size {
            _ = layout.caculate(byParent: parentMeasure)
        }
        
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        let temp = PlaceHolderMeasure()
        temp.py_size = size
        let sizeAfterCalulate = layout.caculate(byParent: temp)
        let fixedSize = Caculator.caculate(size: sizeAfterCalulate, by: size)
        return CGSize(width: fixedSize.width.fixedValue, height: fixedSize.height.fixedValue)
    }
    
}

open class HBox: FlatBox {
    @discardableResult
    public static func attach(_ parent: UIView? = nil, wrap: Bool = true, _ block: PuyoLinkBlock? = nil) -> PuyoLink<HBox> {
        return HBox().attach(parent, wrap: wrap, block)
    }
}

open class VBox: FlatBox {
    
    public static func attach(_ parent: UIView? = nil, wrap: Bool = true, _ block: PuyoLinkBlock? = nil) -> PuyoLink<VBox> {
        return VBox().attach(parent, wrap: wrap, block)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        layout.direction = .y
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

