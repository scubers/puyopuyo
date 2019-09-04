//
//  BoxView.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

public protocol StatefulView {
    associatedtype StateType
    var viewState: State<StateType> { get }
}

public protocol InteractiveView {
    associatedtype InteractType
    var interactor: State<InteractType> { get }
}

public protocol ViewConstructable {
    func buildView() -> UIView
}

open class BoxView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = .init(rawValue: 0)
        buildBody()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(frame: .zero)
        buildBody()
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
        Caculator.adapting(size: size, to: regulator, in: superview?.py_measure ?? Measure())
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

    public func animate(_ interval: TimeInterval, block: @escaping () -> Void) {
        UIView.animate(withDuration: interval, animations: {
            block()
            self.layoutIfNeeded()
        })
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return Caculator.sizeThatFit(size: size, to: regulator)
    }
    
    open func buildBody() {
        
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
