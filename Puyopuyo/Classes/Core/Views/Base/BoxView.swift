//
//  BoxView.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

open class BoxView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = .init(rawValue: 0)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    public var regulator: Regulator {
        return py_measure as! Regulator
    }
    
    private var isLayoutingSubview = false
    
    /// 只应用固有尺寸
    func _selfSizeAdapting(size: Size) {
        if superview is BoxView {
            return
        }
        let parentCGSize = superview?.bounds.size ?? .zero
        let margin = regulator.margin
        
        let wrappedSize = CGSize(width: max(0, parentCGSize.width - margin.left - margin.right),
                                 height: max(0, parentCGSize.height - margin.top - margin.bottom))
        
        // 本身固有尺寸
        if size.isFixed() || size.isRatio() {
            let size = Caculator.caculate(size: size, by: wrappedSize)
            bounds.size = CGSize(width: size.width.fixedValue, height: size.height.fixedValue)
        } else {
            if !size.width.isWrap {
                let width = Caculator.caculateFix(size.width, by: wrappedSize.width)
                bounds.size.width = width.fixedValue
            }
            if !size.height.isWrap {
                let height = Caculator.caculateFix(size.height, by: wrappedSize.height)
                bounds.size.height = height.fixedValue
            }
        }
    }
    
    open override func setNeedsLayout() {
        super.setNeedsLayout()
        // 若自身可能为包裹，则需要通知上层重新布局
        let measure = py_measure
        if let superview = superview as? BoxView, measure.size.maybeWrap() {
            superview.setNeedsLayout()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        _layoutSubviews()
    }

    public func animate(_ interval: TimeInterval, block: () -> Void) {
        block()
        UIView.animate(withDuration: interval, animations: {
            self.layoutIfNeeded()
        })
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return Caculator.sizeThatFit(size: size, to: regulator)
    }
    
    
    // MARK: - 边界相关
    var borders: Borders = Borders()
    
    func _updatingBorders() {
        borders.updateTop(to: layer)
        borders.updateLeft(to: layer)
        borders.updateBottom(to: layer)
        borders.updateRight(to: layer)
    }
}

private extension BoxView {

    func _layoutSubviews() {
        
        guard !isLayoutingSubview else {
            return
        }
        
        isLayoutingSubview = true
        
        let parentMeasure = superview?.py_measure ?? Measure()

        var needResizing = false
        
        _unResizingSubviews {
            // 本身固有尺寸
            _selfSizeAdapting(size: regulator.size)
            // 旧尺寸
            let oldSize = bounds.size
            // 计算后尺寸不可能为包裹
            let sizeAfterCaculate = regulator.caculate(byParent: parentMeasure)
            // 应用计算后的固有尺寸
            _selfSizeAdapting(size: sizeAfterCaculate)
            
            if superview is BoxView {
                // 父视图为布局
            } else {
                // 父视图为普通视图
                let newSize = bounds.size
                center = CGPoint(x: bounds.midX + regulator.margin.left, y: bounds.midY + regulator.margin.top)
                
                // 控制父视图的scroll
                if let scrollView = superview as? UIScrollView, regulator.autoJudgeScroll {
                    if regulator.size.width.isWrap {
                        scrollView.contentSize.width = newSize.width + regulator.padding.left + regulator.padding.right + frame.origin.x
                    }
                    if regulator.size.height.isWrap {
                        scrollView.contentSize.height = newSize.height + regulator.padding.bottom + regulator.padding.top + frame.origin.y
                    }
                }
            }
            
            needResizing = oldSize != bounds.size
        }
        
        if needResizing {
            _ = regulator.caculate(byParent: parentMeasure)
        }
        
        isLayoutingSubview = false
        // 更新边线
        _updatingBorders()
        
    }
    
    func _unResizingSubviews(_ action: () -> Void) {
        autoresizesSubviews = false
        action()
        autoresizesSubviews = true
    }
}
