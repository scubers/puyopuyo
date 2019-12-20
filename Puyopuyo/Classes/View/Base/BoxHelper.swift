//
//  BoxHelper.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/9.
//

import UIKit

public class BoxHelper<R: Regulator> {
    public var isScrollViewControl = false

    public var isSelfPositionControl = true

    public var animator: Animator = Animators.none

    public func layoutSubviews(view: UIView, regulator: R) {
        var layouted = false
        animator.animate(view: view) {
            self._layoutSubviews(view: view, regulator: regulator)
            layouted = true
        }
        assert(layouted, "\(animator) should call `layouting` block!!!!")
    }

    private func _layoutSubviews(view: UIView, regulator: R) {
        let parentMeasure = view.superview?.py_measure ?? Measure()

        // 父视图为布局
        if isBox(view: view.superview) {
            // 当父视图为布局，并且当前view可能是wrap的情况下，父布局在计算的时候已经帮子布局计算完成，所以不需要再次计算
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
                    control(scrollView: superview, by: view, regulator: regulator)
                }
            }
        }

        // 更新边线
        _updatingBorders(view: view)
    }

    private var positionControlUnbinder: Unbinder?
    public func didMoveToSuperview(view: UIView, regulator: R) {
        positionControlUnbinder?.py_unbind()
        if isSelfPositionControl, let spv = view.superview, !isBox(view: spv) {
            positionControlUnbinder =
                SimpleOutput
                .merge([spv.py_frameStateByKVO().asOutput().map({ $0.size }),
                        spv.py_frameStateByBoundsCenter().asOutput().map({ $0.size })])
                .distinct()
                .outputing { [weak self] _ in
                    guard let self = self else { return }
                    if regulator.size.maybeRatio() {
                        self.setNeedsLayout(view: view, regulator: regulator)
                    }
                }
        }
    }

    public func setNeedsLayout(view: UIView, regulator: R) {
        // 若自身可能为包裹，则需要通知上层重新布局
        if regulator.size.maybeWrap(), let superview = view.superview, checkBoxable(view: superview) {
            superview.setNeedsLayout()
        }
    }

    private func checkBoxable(view: UIView?) -> Bool {
        guard let view = view else { return false }
        return view.py_measure is Regulator
    }

    public func sizeThatFits(_ size: CGSize, regulator: R) -> CGSize {
        return Caculator.sizeThatFit(size: size, to: regulator)
    }

    public func control(scrollView: UIScrollView?, by view: UIView, regulator: R) {
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

    func _updatingBorders(view: UIView) {
        borders.updateTop(to: view.layer)
        borders.updateLeft(to: view.layer)
        borders.updateBottom(to: view.layer)
        borders.updateRight(to: view.layer)
    }

    private func isBox(view: UIView?) -> Bool {
        return BoxUtil.isBox(view)
    }
}

public protocol Boxable {
    associatedtype R: Regulator
    var boxHelper: BoxHelper<R> { get }
    var regulator: R { get }
}

struct BoxUtil {
    static func isBox(_ view: UIView?) -> Bool {
        guard let v = view else { return false }
        return v.py_measure is Regulator
    }
}

public typealias BoxBuilder<T> = (T) -> Void
public typealias BoxGenerator<T> = () -> T
