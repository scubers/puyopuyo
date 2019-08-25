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
    
    public var layout: BaseLayout {
        return py_measure as! BaseLayout
    }
    
    /// 只应用固有尺寸
    func _selfSizeAdapting(size: Size) {
        if superview is BoxView {
            return
        }
        let parentCGSize = superview?.bounds.size ?? .zero
        let margin = layout.margin
        
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
        return Caculator.sizeThatFit(size: size, to: layout)
    }
}

private extension BoxView {

    func _layoutSubviews() {
        let parentMeasure = superview?.py_measure ?? Measure()
        let parentCGSize = superview?.bounds.size ?? .zero

        var needResizing = false
        
        _unResizingSubviews {
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
            
            needResizing = oldSize != bounds.size
        }
        
        if needResizing {
            _ = layout.caculate(byParent: parentMeasure)
        }
        
    }
    
    func _unResizingSubviews(_ action: () -> Void) {
        autoresizesSubviews = false
        action()
        autoresizesSubviews = true
    }
}
