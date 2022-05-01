//
//  BoxView.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import UIKit

// MARK: - BoxControl

public class BoxControl {
    ///
    /// Control `contentSize` when superview is UIScrollView
    public var isScrollViewControl = false

    ///
    /// Control `center` when superview is not BoxView
    public var isCenterControl = true

    ///
    /// Control `size` when superview is not BoxView
    public var isSizeControl = true

    public var borders = Borders()
}

public protocol RegulatorSpecifier: AnyObject {
    associatedtype RegulatorType: Regulator
    var regulator: RegulatorType { get }
}

public extension UIView {
    var isBoxView: Bool { self is BoxView }
}

// MARK: - BoxView

open class BoxView: UIView, MeasureChildrenDelegate, BoxLayoutContainer {
    public private(set) var control = BoxControl()

    // MARK: - init

    override public init(frame: CGRect) {
        super.init(frame: frame)
        buildBody()
    }

    public required init?(coder _: NSCoder) {
        super.init(frame: .zero)
        buildBody()
    }

    // MARK: - Open method

    /// override this method to build custom view in subclass
    open func buildBody() {}

    open func createRegulator() -> Regulator {
        fatalError("subclass impl")
    }

    // MARK: - Overrides

    /// when layout once it will be false
    private var initializing = true

    override open func setNeedsLayout() {
        if !initializing {
            // 若自身可能为包裹，则需要通知上层重新布局
            if layoutRegulator.size.maybeWrap(), let superview = superview, superview.isBoxView {
                superview.setNeedsLayout()
            }

            super.setNeedsLayout()

            if layoutRegulator.size.maybeWrap() {
                invalidateIntrinsicContentSize()
            }
        }
    }

    /// indicate if view is calling method layoutSubviews()
    private var layouting = false

    override open func layoutSubviews() {
        if layouting { return }
        layouting = true

        _layoutSubviews()

        initializing = false
        layouting = false
    }

    override open func layoutIfNeeded() {
        if let spv = superview,
           spv.isBoxView,
           spv.layoutMeasure.activated,
           layoutRegulator.activated,
           layoutRegulator.size.maybeWrap()
        {
            // 需要父布局进行计算
            superview?.layoutIfNeeded()
        } else {
            super.layoutIfNeeded()
        }
    }

    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        return CalHelper.sizeThatFit(size: size, to: layoutRegulator)
    }

    override open func didMoveToSuperview() {
        positionControlDisposable?.dispose()
        if control.isCenterControl, let spv = superview, !spv.isBoxView {
            let boundsSize = spv
                .py_observing(\.bounds)
                .map(\.size, .zero)

            positionControlDisposable = boundsSize.distinct().outputing { [weak self] _ in
                guard let self = self else { return }
                if self.layoutRegulator.size.maybeRatio() {
                    self.setNeedsLayout()
                }
            }
        }
    }

    override open func addSubview(_ view: UIView) {
        addLayoutNode(view)
    }

    override open func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)
        layoutChildren.removeAll(where: { $0.layoutNodeView === subview })
    }

    override open var intrinsicContentSize: CGSize {
        if layoutRegulator.size.isRatio() { return .zero }
        if !layoutRegulator.size.isRatio() { return sizeThatFits(.zero) }
        if layoutRegulator.size.maybeFixed() {
            let height: CGFloat = layoutRegulator.size.height.isFixed ? layoutRegulator.size.height.fixedValue : 0
            let width: CGFloat = layoutRegulator.size.width.isFixed ? layoutRegulator.size.width.fixedValue : 0
            return CGSize(width: width, height: height)
        }
        return .zero
    }

    // MARK: Private methods

    private var positionControlDisposable: Disposer?

    private func _layoutSubviews() {
        // 父视图为布局
        if superview?.isBoxView ?? false {
            /**
             1. 当父布局为Box视图，并且当前布局可能是包裹，则视为被上层计算时优先计算过了。当前视图可不用重复计算
             2. 若非包裹，则上层视图时只是用了估算尺寸，需要再次计算子节点
             */
            if layoutRegulator.size.bothNotWrap() {
                let layoutResidual = CalculateUtil.getSelfLayoutResidual(for: layoutRegulator, fromContentResidual: bounds.size)
                _ = CalHelper.calculateIntrinsicSize(for: layoutRegulator, layoutResidual: layoutResidual, strategy: .calculate)
            }
        } else {
            var layoutResidual: CGSize
            // 父视图为普通视图
            if control.isSizeControl {
                layoutResidual = CalculateUtil.getInitialLayoutResidual(for: layoutRegulator)

                if let spv = superview {
                    let spvBounds = spv.bounds.size
                    if layoutRegulator.size.width.isRatio { layoutResidual.width = spvBounds.width }
                    if layoutRegulator.size.height.isRatio { layoutResidual.height = spvBounds.height }
                }

                layoutRegulator.calculatedSize = CalHelper.calculateIntrinsicSize(for: layoutRegulator, layoutResidual: layoutResidual, strategy: .calculate)
            } else {
                /**
                 1. 当不需要布局控制自身大小时，意味着外部已经给本布局设置好了尺寸，即可以反推出当前布局可用的剩余空间
                 2. 因为布局自身已经被限定尺寸大小，所以布局尺寸只能是撑满剩余空间
                 */

                if !layoutRegulator.size.isRatio() {
                    DiagnosisUitl.constraintConflict(crash: false, "if isSelfSizeControl == false, regulator's size should be fill. regulator's size will reset to fill")
                    layoutRegulator.size = .init(width: .fill, height: .fill)
                }

                layoutResidual = CalculateUtil.getSelfLayoutResidual(for: layoutRegulator, fromContentResidual: bounds.size)
                layoutRegulator.calculatedSize = CalHelper.calculateIntrinsicSize(for: layoutRegulator, layoutResidual: layoutResidual, strategy: .calculate)
            }

            if control.isCenterControl {
                let b = CGRect(origin: .zero, size: layoutRegulator.calculatedSize)
                layoutRegulator.calculatedCenter = CGPoint(x: b.midX + layoutRegulator.margin.left, y: b.midY + layoutRegulator.margin.top)
            }

            if control.isScrollViewControl, let superview = superview as? UIScrollView {
                control(scrollView: superview)
            }

            let animator = py_animator ?? Animators.inherited

            animator.animate(self, size: layoutRegulator.calculatedSize, center: layoutRegulator.calculatedCenter) {
                if self.control.isSizeControl {
                    self.bounds.size = self.layoutRegulator.calculatedSize
                }
                if self.control.isCenterControl {
                    self.center = self.layoutRegulator.calculatedCenter
                }
            }
        }

        // 获取最近的animator
        let animator = py_animator ?? getInheritedBoxAnimator(self) ?? Animators.inherited
        // 处理子节点的位置和大小

        // 处理虚拟节点的center
        fixVirtualGroupCenter()

        // 实际赋值位置大小
        subviews.forEach { v in
            if v.layoutMeasure.activated {
                self.applyViewPosition(v, inheritedAnimator: animator)
            }
        }

        // 更新边线
        updatingBorders()
    }

    private func updatingBorders() {
        control.borders.updateTop(to: layer)
        control.borders.updateLeft(to: layer)
        control.borders.updateBottom(to: layer)
        control.borders.updateRight(to: layer)
    }

    public func control(scrollView: UIScrollView?) {
        guard let scrollView = scrollView else { return }
        let newSize = layoutRegulator.calculatedSize
        // 控制父视图的scroll
        if layoutRegulator.size.width.isWrap {
            scrollView.contentSize.width = newSize.width + layoutRegulator.margin.left + layoutRegulator.margin.right
        }
        if layoutRegulator.size.height.isWrap {
            scrollView.contentSize.height = newSize.height + layoutRegulator.margin.bottom + layoutRegulator.margin.top
        }
    }

    private func getInheritedBoxAnimator(_ view: UIView?) -> Animator? {
        if let ani = view?.py_animator {
            return ani
        } else if view?.superview?.isBoxView ?? false {
            return getInheritedBoxAnimator(view?.superview)
        } else {
            return nil
        }
    }

    private func applyViewPosition(_ subView: UIView, inheritedAnimator: Animator? = nil) {
        let measure = subView.layoutMeasure

        let animator = subView.py_animator
            ?? inheritedAnimator
            ?? Animators.inherited

        animator.animate(subView, size: measure.calculatedSize, center: measure.calculatedCenter) {
            subView.bounds.size = measure.calculatedSize
            subView.center = measure.calculatedCenter
        }
    }

    private func fixVirtualGroupCenter() {
        layoutChildren.forEach { node in
            if let node = node as? BoxLayoutContainer {
                node.fixChildrenCenterByHostPosition()
            }
        }
    }

    // MARK: - ViewParasitizing

    public func addParasite(_ parasite: ViewDisplayable) {
        super.addSubview(parasite.dislplayView)
    }

    public func removeParasite(_ parasite: ViewDisplayable) {
        if parasite.dislplayView.superview == self {
            parasite.dislplayView.removeFromSuperview()
        }
    }

    // MARK: - BoxLayoutContainer

    public var layoutRegulator: Regulator { layoutMeasure as! Regulator }

    public var layoutChildren: [BoxLayoutNode] = []

    // MARK: - MeasureChildrenDelegate

    public func children(for _: Measure) -> [Measure] {
        layoutChildren.filter {
            if !$0.layoutNodeType.isVirtual {
                return $0.layoutNodeView?.superview == self
            }
            return true
        }.map(\.layoutMeasure)
    }
}

open class GenericBoxView<R: Regulator>: BoxView, RegulatorSpecifier {
    public var regulator: R { layoutRegulator as! R }
}
