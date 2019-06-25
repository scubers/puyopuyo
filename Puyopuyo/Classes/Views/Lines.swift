
//
//  File.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import Foundation

public enum Visiblity {
    case visible
    case invisible
    case gone
}

public enum VAligment {
    case top
    case bottom
    case center
}

public enum HAligment {
    case left
    case right
    case center
}

open class LayoutView: UIView {
}

open class Line: LayoutView {
    
    public var layout: LineLayout {
        return py_measure as! LineLayout
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let parentMeasure = superview?.py_measure ?? Measure()
        
        // 如果原本就固定尺寸
        if layout.unit.size.isFixed() {
            // 此时可以设置自己的尺寸
//            let originFixedSize = PuyoUtil.cgSize(from: layout.size, by: layout.direction)
//            let originFixedSize = PuyoUtil.cgSize(from: layout.size, parentDirection: parentMeasure.direction)
//            bounds.size = originFixedSize
            bounds.size = CGSize(width: layout.unit.size.width.value, height: layout.unit.size.height.value)
        }
        
        // 旧尺寸
        let oldSize = bounds.size
        
        let sizeAfterCaculate = LineCaculator.caculateLine(layout, from: parentMeasure)
        
        if (superview?.py_measure is LineLayout) {
            // 父视图为布局视图
            // 通过计算如果已经确定了尺寸，也可以直接设置
            if sizeAfterCaculate.isFixed() {
//                let newSize = PuyoUtil.cgSize(from: sizeAfterCaculate, parentDirection: parentMeasure.direction)
//                bounds.size = newSize
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
//                let fixedValue = parentMeasure.direction == .y ? parentCGSize.height : parentCGSize.width
                widthSize = .fixed(parentCGSize.width * ratio)
            }
            
            var heightSize = sizeAfterCaculate.height
            if case .ratio(let ratio) = heightSize {
//                let fixedValue = parentMeasure.direction == .y ? parentCGSize.width : parentCGSize.height
                heightSize = .fixed(parentCGSize.height * ratio)
            }
            
//            let newSize = PuyoUtil.cgSize(from: Size(main: widthSize, cross: heightSize), parentDirection: parentMeasure.direction)
            let newSize = CGSize(width: widthSize.value, height: heightSize.value)
            
            bounds.size = newSize
            
            if oldSize != newSize {
                _ = LineCaculator.caculateLine(layout, from: parentMeasure)
            }
            
            center = CGPoint(x: bounds.midX, y: bounds.midY)
        }
        
        /*
        let oldSize = bounds.size
        
        var mainSize = size.main
        if mainSize.isRatio {
            mainSize = .fixed(0)
        }
        
        var crossSize = size.cross
        if crossSize.isRatio {
            crossSize = .fixed(0)
        }
        
        let newSize = PuyoUtil.cgSize(from: Size(main: mainSize, cross: crossSize), by: layout.direction)
        
        bounds.size = newSize
        
        if oldSize != newSize {
            _ = LineCaculator.caculateLine(layout)
        }
        
        if !(superview is LayoutView) {
            // 父视图为非布局视图时，需要根据margin设定自己的center
            center = CGPoint(x: bounds.midX, y: bounds.midY)
        }
        */
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

