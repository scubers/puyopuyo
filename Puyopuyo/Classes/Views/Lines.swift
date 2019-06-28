
//
//  File.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import Foundation

open class LayoutView: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = .init(rawValue: 0)
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    open override func setNeedsLayout() {
        super.setNeedsLayout()
        // 如果自己是固定尺寸，则不需要通知上层进行布局
        let measure = py_measure
        if let superview = superview as? LayoutView, (measure.size.width.isWrap || measure.size.height.isWrap) {
            superview.setNeedsLayout()
        }
    }
}

open class Line: LayoutView {
    
    public var layout: LineLayout {
        return py_measure as! LineLayout
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let parentMeasure = superview?.py_measure ?? Measure()
        
        // 如果原本就固定尺寸
        if layout.size.isFixed() {
            // 此时可以设置自己的尺寸
            bounds.size = CGSize(width: layout.size.width.fixedValue, height: layout.size.height.fixedValue)
        }
        
        // 旧尺寸
        let oldSize = bounds.size
        
        let sizeAfterCaculate = LineCaculator.caculateLine(layout, from: parentMeasure)
        
        if (superview?.py_measure is LineLayout) {
            // 父视图为布局视图
            // 通过计算如果已经确定了尺寸，也可以直接设置
            if sizeAfterCaculate.isFixed() {
                bounds.size = CGSize(width: sizeAfterCaculate.width.fixedValue, height: sizeAfterCaculate.height.fixedValue)
            }
            if oldSize != bounds.size {
                _ = LineCaculator.caculateLine(layout, from: parentMeasure)
            }
            
        } else {
            // 父视图为非布局视图
            let parentCGSize = superview?.bounds ?? .zero

            let fixedSize = Caculator.caculate(size: sizeAfterCaculate, by: parentCGSize.size)
            let newSize = CGSize(width: fixedSize.width.fixedValue, height: fixedSize.height.fixedValue)
            
            bounds.size = newSize
            
            if oldSize != newSize {
                _ = LineCaculator.caculateLine(layout, from: parentMeasure)
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
        let sizeAfterCalulate = LineCaculator.caculateLine(layout, from: PlaceHolderMeasure())
        let fixedSize = Caculator.caculate(size: sizeAfterCalulate, by: size)
        return CGSize(width: fixedSize.width.fixedValue, height: fixedSize.height.fixedValue)
    }
    
}

open class HLine: Line {
    public static func attach(_ parent: UIView? = nil, wrap: Bool = true, _ block: PuyoLinkBlock? = nil) -> PuyoLink<HLine> {
        return HLine().attach(parent, wrap: wrap, block)
    }
    open override func layoutSubviews() {
        super.layoutSubviews()
        print("lines layout")
    }
}

open class VLine: Line {
    
    public static func attach(_ parent: UIView? = nil, wrap: Bool = true, _ block: PuyoLinkBlock? = nil) -> PuyoLink<VLine> {
        return VLine().attach(parent, wrap: wrap, block)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        layout.direction = .y
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

