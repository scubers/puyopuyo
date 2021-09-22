//
//  BoxHelper.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/9.
//

import UIKit

public class BoxControl<R: Regulator> {
    public var isScrollViewControl = false

    public var isCenterControl = true
    public var isSizeControl = true

    public var animateChildren = false

    func layoutSubviews(view: UIView, regulator: R) {
        // 父视图为布局
        if isBox(view: view.superview) {
            /**
             1. 当父布局为Box视图，并且当前布局可能是包裹，则视为被上层计算时优先计算过了。当前视图可不用重复计算
             2. 若非包裹，则上层视图时只是用了估算尺寸，需要再次计算子节点
             */
            if regulator.size.bothNotWrap(), !regulator.calculateChildrenImmediately {
                let residual = CGSize(width: view.bounds.width + regulator.margin.getHorzTotal(),
                                      height: view.bounds.height + regulator.margin.getVertTotal())
                _ = Calculator.calculateIntrinsicSize(for: regulator, residual: residual, calculateChildrenImmediately: true)
            }
        } else {
            // 父视图为普通视图
            let ani = view.py_animator ?? Animators.none
            if isSizeControl {
                /**
                 当需要控制自身大小时，剩余空间为父视图的所有空间
                 */
                var residual = view.superview?.bounds.size ?? .zero
                if regulator.size.width.isWrap {
                    residual.width = regulator.size.width.max - regulator.margin.getHorzTotal()
                }
                if regulator.size.height.isWrap {
                    residual.height = regulator.size.height.max - regulator.margin.getVertTotal()
                }
                regulator.calculatedSize = Calculator.calculateIntrinsicSize(for: regulator, residual: residual, calculateChildrenImmediately: true)
                regulator.applyCalculatedSize()
            } else {
                /**
                 1. 当不需要布局控制自身大小时，意味着外部已经给本布局设置好了尺寸，即可以反推出当前布局可用的剩余空间
                 2. 因为布局自身已经被限定尺寸大小，所以布局尺寸只能是撑满剩余空间
                 */

                if regulator.size != Size(width: .fill, height: .fill) {
                    Calculator.constraintConflict(crash: false, "if isSelfSizeControl == false, regulator's size should be fill. regulator's size will reset to fill")
                    regulator.size = .init(width: .fill, height: .fill)
                }
                var residual = view.bounds.size
                residual.width += regulator.margin.getHorzTotal()
                residual.height += regulator.margin.getVertTotal()

                _ = Calculator.calculateIntrinsicSize(for: regulator, residual: residual, calculateChildrenImmediately: true)
            }
            if isCenterControl {
                let b = CGRect(origin: .zero, size: regulator.calculatedSize)
                regulator.calculatedCenter = CGPoint(x: b.midX + regulator.margin.left, y: b.midY + regulator.margin.top)
                regulator.applyCalculatedCenter()
            }

            if isScrollViewControl, let superview = view.superview as? UIScrollView {
                control(scrollView: superview, by: view, regulator: regulator)
            }
        }

        // 获取最近的animator
        let animator = view.py_animator ?? getInheritedBoxAnimator(view) ?? Animators.none
        // 处理子节点的位置和大小
        animator.animate(view, size: regulator.calculatedSize, center: regulator.calculatedCenter) {
            view.subviews.forEach { v in
                if v.py_measure.activated {
                    self.applyViewPosition(v)
                }
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
        guard measure.sizeChanged || measure.centerChanged else {
            return
        }

        let animator = subView.py_animator
            ?? (animateChildren ? inheritedAnimator : nil)
            ?? Animators.none

        animator.animate(measure.getRealDelegate(), size: measure.calculatedSize, center: measure.calculatedCenter) {
            measure.applyCalculatedPosition()
        }
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
        BoxUtil.isBox(view)
    }
}

public protocol Boxable {
    associatedtype RegulatorType: Regulator
    var control: BoxControl<RegulatorType> { get }
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
