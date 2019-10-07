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

public protocol EventableView {
    associatedtype EventType
    var eventProducer: SimpleIO<EventType> { get }
}

open class BoxView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        buildBody()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(frame: .zero)
        buildBody()
    }
    
    public var isScrollViewControl = false
    public var isSelfPositionControl = true
    
    public var regulator: Regulator {
        return py_measure as! Regulator
    }
    
    open override func setNeedsLayout() {
        super.setNeedsLayout()
        // 若自身可能为包裹，则需要通知上层重新布局
        if regulator.size.maybeWrap(), let superview = superview as? BoxView {
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
    
    private var positionControlUnbinder: Unbinder?
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        positionControlUnbinder?.py_unbind()
        if isSelfPositionControl, let spv = superview, !(spv is BoxView) {
            positionControlUnbinder =
            SimpleOutput
                .merge([spv.py_frameStateByKVO().asOutput().map({ $0.size }),
                        spv.py_frameStateByBoundsCenter().asOutput().map({ $0.size })])
                .distinct()
                .outputing { [weak self] (_) in
                    guard let self = self else { return }
                    if self.regulator.size.maybeRatio() {
                        self.setNeedsLayout()
                    }
                }
        }
    }
    
    deinit {
        positionControlUnbinder?.py_unbind()
    }
}

private extension BoxView {

    func _layoutSubviews() {
        
        let parentMeasure = superview?.py_measure ?? Measure()

        let sizeAfterCaculate = regulator.caculate(byParent: parentMeasure)
        // 应用计算后的固有尺寸
        if superview is BoxView {
            // 父视图为布局
        } else if isSelfPositionControl {
            // 父视图为普通视图
            Caculator.adapting(size: sizeAfterCaculate, to: regulator, in: parentMeasure)
            center = CGPoint(x: bounds.midX + regulator.margin.left, y: bounds.midY + regulator.margin.top)
            
            let newSize = bounds.size
            // 控制父视图的scroll
            if isScrollViewControl, let scrollView = superview as? UIScrollView {
                if regulator.size.width.isWrap {
                    scrollView.contentSize.width = newSize.width + regulator.margin.left + regulator.margin.right
                }
                if regulator.size.height.isWrap {
                    scrollView.contentSize.height = newSize.height + regulator.margin.bottom + regulator.margin.top
                }
            }
        }
            
        // 更新边线
        _updatingBorders()
        
    }
    
}
