//
//  BoxHelper.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/9.
//

import UIKit

public class BoxControl<R: Regulator> {
    ///
    /// Control `contentSize` when superview is UIScrollView
    public var isScrollViewControl = false

    ///
    /// Control `center` when superview is not BoxView
    public var isCenterControl = true

    ///
    /// Control `size` when superview is not BoxView
    public var isSizeControl = true

    func layoutSubviews(for view: UIView, regulator: R) {
        // 父视图为布局
        if isBox(view: view.superview) {
            /**
             1. 当父布局为Box视图，并且当前布局可能是包裹，则视为被上层计算时优先计算过了。当前视图可不用重复计算
             2. 若非包裹，则上层视图时只是用了估算尺寸，需要再次计算子节点
             */
            if regulator.size.bothNotWrap() {
                let layoutResidual = CGSize(
                    width: view.bounds.width + regulator.margin.getHorzTotal(),
                    height: view.bounds.height + regulator.margin.getVertTotal()
                )
                _ = CalHelper.calculateIntrinsicSize(for: regulator, layoutResidual: layoutResidual, strategy: .positive)
            }
        } else {
            var layoutResidual: CGSize
            // 父视图为普通视图
            if isSizeControl {
                /**
                 当需要控制自身大小时，剩余空间为父视图的所有空间
                 */

                layoutResidual = CalculateUtil.getInitialLayoutResidual(for: regulator)

                if let spv = view.superview {
                    let spvBounds = spv.bounds.size
                    if regulator.size.width.isRatio { layoutResidual.width = spvBounds.width }
                    if regulator.size.height.isRatio { layoutResidual.height = spvBounds.height }
                }

                regulator.calculatedSize = CalHelper.calculateIntrinsicSize(for: regulator, layoutResidual: layoutResidual, strategy: .lazy)
            } else {
                /**
                 1. 当不需要布局控制自身大小时，意味着外部已经给本布局设置好了尺寸，即可以反推出当前布局可用的剩余空间
                 2. 因为布局自身已经被限定尺寸大小，所以布局尺寸只能是撑满剩余空间
                 */

                if !regulator.size.isRatio() {
                    DiagnosisUitl.constraintConflict(crash: false, "if isSelfSizeControl == false, regulator's size should be fill. regulator's size will reset to fill")
                    regulator.size = .init(width: .fill, height: .fill)
                }

                layoutResidual = CalculateUtil.getLayoutResidual(for: regulator, fromContentResidual: view.bounds.size)
                regulator.calculatedSize = CalHelper.calculateIntrinsicSize(for: regulator, layoutResidual: layoutResidual, strategy: .lazy)
            }

            if isCenterControl {
                let b = CGRect(origin: .zero, size: regulator.calculatedSize)
                regulator.calculatedCenter = CGPoint(x: b.midX + regulator.margin.left, y: b.midY + regulator.margin.top)
            }

            if isScrollViewControl, let superview = view.superview as? UIScrollView {
                control(scrollView: superview, by: view, regulator: regulator)
            }

            let animator = view.py_animator ?? Animators.inherited

            animator.animate(view, size: regulator.calculatedSize, center: regulator.calculatedCenter) {
                if self.isSizeControl {
                    view.bounds.size = regulator.calculatedSize
                }
                if self.isCenterControl {
                    view.center = regulator.calculatedCenter
                }
            }

            if regulator.size.bothNotWrap() {
                // 非包裹，必须获取当前尺寸后再次布局子系统
                _ = CalHelper.calculateIntrinsicSize(for: regulator, layoutResidual: layoutResidual, strategy: .positive)
            }
        }

        // 获取最近的animator
        let animator = view.py_animator ?? getInheritedBoxAnimator(view) ?? Animators.inherited
        // 处理子节点的位置和大小

        view.subviews.forEach { v in
            if v.py_measure.activated {
                self.applyViewPosition(v, inheritedAnimator: animator)
            }
        }

        // 更新边线
        _updatingBorders(view: view)
    }

    private func getInheritedBoxAnimator(_ view: UIView?) -> Animator? {
        if let ani = view?.py_animator {
            return ani
        } else if BoxUtil.isBox(view?.superview) {
            return getInheritedBoxAnimator(view?.superview)
        } else {
            return nil
        }
    }

    private func applyViewPosition(_ subView: UIView, inheritedAnimator: Animator? = nil) {
        let measure = subView.py_measure

        let animator = subView.py_animator
            ?? inheritedAnimator
            ?? Animators.inherited

        animator.animate(subView, size: measure.calculatedSize, center: measure.calculatedCenter) {
            subView.bounds.size = measure.calculatedSize
            subView.center = measure.calculatedCenter
        }
    }

    private var positionControlDisposable: Disposer?
    public func didMoveToSuperview(view: UIView, regulator: R) {
        positionControlDisposable?.dispose()
        if isCenterControl, let spv = view.superview, !isBox(view: spv) {
            let boundsSize = spv
                .py_observing(\.bounds)
                .map(\.size, .zero)

            positionControlDisposable = boundsSize.distinct().outputing { [weak view] _ in
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
        return CalHelper.sizeThatFit(size: size, to: regulator)
    }

    public func control(scrollView: UIScrollView?, by view: UIView, regulator: R) {
        guard let scrollView = scrollView else { return }
        let newSize = regulator.calculatedSize
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
        BoxUtil.isBox(view)
    }
}

public protocol Boxable {
    associatedtype RegulatorType: Regulator
    var control: BoxControl<RegulatorType> { get }
    var regulator: RegulatorType { get }
}

public extension Boxable {
    @available(*, deprecated, message: "Use [control]")
    var boxHelper: BoxControl<RegulatorType> { control }
}

enum BoxUtil {
    static func isBox(_ view: UIView?) -> Bool {
        guard let v = view else { return false }
        return v.py_measure is Regulator
    }
}

public typealias BoxBuilder<T> = (T) -> Void
public typealias BoxGenerator<T> = () -> T
