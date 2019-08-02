
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
//        old()
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
    
    /// 只应用固有尺寸
    private func _selfSizeAdapting(size: Size) {
        let parentCGSize = superview?.bounds.size ?? .zero
        // 本身固有尺寸
        if size.isFixed() {
            let size = Caculator.caculate(size: size, by: parentCGSize)
            bounds.size = CGSize(width: size.width.fixedValue, height: size.height.fixedValue)
        } else if size.width.isFixed {
            let width = Caculator.caculateFix(width: size.width, by: parentCGSize.width)
            bounds.size.width = width.fixedValue
        } else if size.height.isFixed {
            let height = Caculator.caculateFix(width: size.height, by: parentCGSize.height)
            bounds.size.height = height.fixedValue
        }
    }
    
    private func old() {
        
        let parentMeasure = superview?.py_measure ?? Measure()
        let parentCGSize = superview?.bounds.size ?? .zero
        // 如果原本就固定尺寸
        if layout.size.bothNotWrap() {
            // 此时可以设置自己的尺寸
            let size = Caculator.caculate(size: layout.size, by: superview?.bounds.size ?? .zero)
            bounds.size = CGSize(width: size.width.fixedValue, height: size.height.fixedValue)
        }
        
        // 旧尺寸
        let oldSize = bounds.size
        
        let sizeAfterCaculate = layout.caculate(byParent: parentMeasure)
        
        if (superview is BoxView) {
            // 父视图为布局视图
            // 通过计算如果已经确定了尺寸，也可以直接设置
            if sizeAfterCaculate.bothNotWrap() {
                var inputSize = parentCGSize
                inputSize.width -= (layout.margin.left + layout.margin.right)
                inputSize.height -= (layout.margin.top + layout.margin.bottom)
                let size = Caculator.caculate(size: sizeAfterCaculate, by: inputSize)
                bounds.size = CGSize(width: size.width.fixedValue, height: size.height.fixedValue)
            }
            if oldSize != bounds.size {
                _ = layout.caculate(byParent: parentMeasure)
                //                _ = FlatCaculator.caculateLine(layout, from: parentMeasure)
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

