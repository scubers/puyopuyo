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

public protocol Animator {
    func animate(view: BoxView, layouting: @escaping () -> Void)
}

public struct Animators {
    /// no animation
    public static let none: Animator = NonAnimator()

    /// default animation
    public static let `default`: Animator = DefaultAnimator()

    struct NonAnimator: Animator {
        public func animate(view _: BoxView, layouting: @escaping () -> Void) {
            layouting()
        }
    }

    struct DefaultAnimator: Animator {
        func animate(view _: BoxView, layouting: @escaping () -> Void) {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 5, options: .curveEaseOut, animations: layouting, completion: nil)
        }
    }
}

open class BoxView: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        buildBody()
    }

    public required init?(coder _: NSCoder) {
        super.init(frame: .zero)
        buildBody()
    }

    public var isScrollViewControl = false
    public var isSelfPositionControl = true

    public var animator: Animator = Animators.none

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
        var layouted = false
        animator.animate(view: self) {
            self._layoutSubviews()
            layouted = true
        }
        assert(layouted, "\(animator) should call `layouting` block!!!!")
    }

    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return Caculator.sizeThatFit(size: size, to: regulator)
    }

    open func buildBody() {}

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
                .outputing { [weak self] _ in
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

        // 应用计算后的固有尺寸
        if superview is BoxView {
            // 父视图为布局
            if regulator.size.bothNotWrap() {
                _ = regulator.caculate(byParent: parentMeasure, remain: Caculator.remainSize(with: bounds.size, margin: regulator.margin))
            }
        } else {
            // 父视图为普通视图
            let sizeAfterCaculate = regulator.caculate(byParent: parentMeasure, remain: parentMeasure.py_size)
            Caculator.adapting(size: sizeAfterCaculate, to: regulator, remain: parentMeasure.py_size)
            if isSelfPositionControl {
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
        }

        // 更新边线
        _updatingBorders()
    }
}
