//
//  BoxHelper.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/9.
//

import UIKit

public class BoxHelper<R: Regulator> {
    public var isScrollViewControl = false

    @available(*, deprecated)
    public var isSelfPositionControl: Bool {
        get { isCenterControl }
        set { isCenterControl = newValue }
    }

    public var isCenterControl = true
    public var isSizeControl = true

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
            //
            if regulator.size.bothNotWrap() {
                let residual = CGSize(width: view.bounds.width + regulator.margin.getHorzTotal(),
                                    height: view.bounds.height + regulator.margin.getVertTotal())
                _ = regulator.calculate(by: residual)
            }
        } else {
            if isSizeControl {
                // 父视图为普通视图
                var size = parentMeasure.py_size
                if regulator.size.width.isWrap {
                    size.width = regulator.size.width.max
                }
                if regulator.size.height.isWrap {
                    size.height = regulator.size.height.max
                }
                // 父视图为非Regulator，需要事先应用一下固有尺寸
                Calculator.applyMeasure(regulator, size: regulator.size, currentResidual: size)
                let sizeAftercalculate = regulator.calculate(by: size)
                Calculator.applyMeasure(regulator, size: sizeAftercalculate, currentResidual: size)
            } else {
                Calculator.constraintConflict(crash: false, "if isSelfSizeControl == false, regulator's size should be fill. regulator's size will reset to fill")
                regulator.size = .init(width: .fill, height: .fill)
                _ = regulator.calculate(by: view.bounds.size)
            }
            if isCenterControl {
                view.center = CGPoint(x: view.bounds.midX + regulator.margin.left, y: view.bounds.midY + regulator.margin.top)
            }
            if isScrollViewControl, let superview = view.superview as? UIScrollView {
                control(scrollView: superview, by: view, regulator: regulator)
            }
        }

        // 更新边线
        _updatingBorders(view: view)
    }

    private var positionControlDisposable: Disposer?
    public func didMoveToSuperview(view: UIView, regulator: R) {
        positionControlDisposable?.dispose()
        if isCenterControl, let spv = view.superview, !isBox(view: spv) {
            let frameSize = spv
                .py_observing(\.frame)
                .map(\.size, .zero)

            let boundsSize = spv
                .py_observing(\.bounds)
                .map(\.size, .zero)

            positionControlDisposable =
                Outputs
                    .merge([frameSize, boundsSize])
                    .distinct()
                    .outputing { [weak view] _ in
                        guard let view = view else { return }
                        if regulator.size.maybeRatio() {
                            view.setNeedsLayout()
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
        return Calculator.sizeThatFit(size: size, to: regulator)
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

    var borders = Borders()

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
    associatedtype RegulatorType: Regulator
    var boxHelper: BoxHelper<RegulatorType> { get }
    var regulator: RegulatorType { get }
}

enum BoxUtil {
    static func isBox(_ view: UIView?) -> Bool {
        guard let v = view else { return false }
        return v.py_measure is Regulator
    }
}

public typealias BoxBuilder<T> = (T) -> Void
public typealias BoxGenerator<T> = () -> T
