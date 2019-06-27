
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
            bounds.size = CGSize(width: layout.size.width.value, height: layout.size.height.value)
        }
        
        // 旧尺寸
        let oldSize = bounds.size
        
        let sizeAfterCaculate = LineCaculator.caculateLine(layout, from: parentMeasure)
        
        if (superview?.py_measure is LineLayout) {
            // 父视图为布局视图
            // 通过计算如果已经确定了尺寸，也可以直接设置
            if sizeAfterCaculate.isFixed() {
                bounds.size = CGSize(width: sizeAfterCaculate.width.value, height: sizeAfterCaculate.height.value)
            }
            if oldSize != bounds.size {
                _ = LineCaculator.caculateLine(layout, from: parentMeasure)
            }
            
        } else {
            // 父视图为非布局视图
            let parentCGSize = superview?.bounds ?? .zero
            
            var widthSize = sizeAfterCaculate.width
            if case .ratio(let ratio) = widthSize {
                widthSize = .fixed(parentCGSize.width * ratio)
            }
            
            var heightSize = sizeAfterCaculate.height
            if case .ratio(let ratio) = heightSize {
                heightSize = .fixed(parentCGSize.height * ratio)
            }
            
            let newSize = CGSize(width: widthSize.value, height: heightSize.value)
            
            bounds.size = newSize
            
            if oldSize != newSize {
                _ = LineCaculator.caculateLine(layout, from: parentMeasure)
            }
            
            center = CGPoint(x: bounds.midX, y: bounds.midY)
        }
        
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        let temp = PlaceHolderMeasure()
        temp.py_size = size
        let sizeAfterCalulated = LineCaculator.caculateLine(layout, from: PlaceHolderMeasure())
        var widthSize = sizeAfterCalulated.width
        if case .ratio(let ratio) = widthSize {
            widthSize = .fixed(size.width * ratio)
        }
        
        var heightSize = sizeAfterCalulated.height
        if case .ratio(let ratio) = heightSize {
            heightSize = .fixed(size.height * ratio)
        }
        return CGSize(width: widthSize.value, height: heightSize.value)
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
    }
}

open class HLine: Line {
}

open class VLine: Line {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        layout.direction = .y
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

