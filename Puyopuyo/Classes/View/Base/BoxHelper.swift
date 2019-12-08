//
//  BoxHelper.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/9.
//

import UIKit

public class BoxHelper {
    public var regulator: Regulator

    weak var _view: UIView?
    let temp = UIView()
    var view: UIView { _view ?? temp }

    public init(regulator: Regulator, view: UIView) {
        self.regulator = regulator
        _view = view
    }

    public var isScrollViewControl = false

    public var isSelfPositionControl = true

    public var animator: Animator = Animators.none

    public func layoutSubviews() {
        var layouted = false
        animator.animate(view: view as! BoxView) {
            self._layoutSubviews()
            layouted = true
        }
        assert(layouted, "\(animator) should call `layouting` block!!!!")
    }

    private func _layoutSubviews() {
        let parentMeasure = view.superview?.py_measure ?? Measure()

        // 应用计算后的固有尺寸
        if view.superview is BoxView {
            // 父视图为布局
            if regulator.size.bothNotWrap() {
                _ = regulator.caculate(byParent: parentMeasure, remain: Caculator.remainSize(with: view.bounds.size, margin: regulator.margin))
            }
        } else {
            // 父视图为普通视图
            let sizeAfterCaculate = regulator.caculate(byParent: parentMeasure, remain: parentMeasure.py_size)
            Caculator.adapting(size: sizeAfterCaculate, to: regulator, remain: parentMeasure.py_size)
            if isSelfPositionControl {
                view.center = CGPoint(x: view.bounds.midX + regulator.margin.left, y: view.bounds.midY + regulator.margin.top)
                
                if isScrollViewControl, let superview = view.superview as? UIScrollView {
                    control(scrollView: superview)
                }
            }
        }
        
        control(scrollView: view as? UIScrollView)

        // 更新边线
        _updatingBorders()
    }

    private var positionControlUnbinder: Unbinder?
    public func didMoveToSuperview() {
        positionControlUnbinder?.py_unbind()
        if isSelfPositionControl, let spv = view.superview, !(spv is BoxView) {
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

    public func setNeedsLayout() {
        // 若自身可能为包裹，则需要通知上层重新布局
        if regulator.size.maybeWrap(), let superview = view.superview as? BoxView {
            superview.setNeedsLayout()
        }
    }

    public func sizeThatFits(_ size: CGSize) -> CGSize {
        return Caculator.sizeThatFit(size: size, to: regulator)
    }

    public func control(scrollView: UIScrollView?) {
        guard let scrollView = scrollView else { return }
        let newSize = view.bounds.size
        // 控制父视图的scroll
        if regulator.size.width.isWrap {
            scrollView.contentSize.width = newSize.width + regulator.margin.left + regulator.margin.right
        }
        if regulator.size.height.isWrap {
            scrollView.contentSize.height = newSize.height + regulator.margin.bottom + regulator.margin.top
        }
    }

    var borders: Borders = Borders()

    func _updatingBorders() {
        borders.updateTop(to: view.layer)
        borders.updateLeft(to: view.layer)
        borders.updateBottom(to: view.layer)
        borders.updateRight(to: view.layer)
    }
}
