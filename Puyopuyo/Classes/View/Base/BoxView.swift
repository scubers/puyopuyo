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

public protocol RegulatorView {
    func createRegulator() -> Regulator
}

public extension UIView {
    var isBoxView: Bool { self is RegulatorView }
}

public protocol IBoxView: RegulatorSpecifier {
    var control: BoxControl { get }
}

// MARK: - BoxView

open class BoxView<RegulatorType: Regulator>:
    UIView,
    IBoxView,
    RegulatorView,
    MeasureChildrenDelegate,
    BoxLayoutContainer
{
    public private(set) var control = BoxControl()

    public var regulator: RegulatorType { py_measure as! RegulatorType }

    public func createRegulator() -> Regulator {
        fatalError("subclass impl")
    }

    // MARK: - init

    override public init(frame: CGRect) {
        super.init(frame: frame)
        buildBody()
    }

    public required init?(coder _: NSCoder) {
        super.init(frame: .zero)
        buildBody()
    }

    // MARK: - custom method

    /// override this method to build custom view in subclass
    open func buildBody() {}

    // MARK: - Overrides

    /// when layout once it will be false
    private var initializing = true

    override open func setNeedsLayout() {
        if !initializing {
            // 若自身可能为包裹，则需要通知上层重新布局
            if regulator.size.maybeWrap(), let superview = superview, superview.isBoxView {
                superview.setNeedsLayout()
            }

            super.setNeedsLayout()

            if regulator.size.maybeWrap() {
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
           spv.py_measure.activated,
           regulator.activated,
           regulator.size.maybeWrap()
        {
            // 需要父布局进行计算
            superview?.layoutIfNeeded()
        } else {
            super.layoutIfNeeded()
        }
    }

    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        return CalHelper.sizeThatFit(size: size, to: regulator)
    }

    override open func didMoveToSuperview() {
        positionControlDisposable?.dispose()
        if control.isCenterControl, let spv = superview, !spv.isBoxView {
            let boundsSize = spv
                .py_observing(\.bounds)
                .map(\.size, .zero)

            positionControlDisposable = boundsSize.distinct().outputing { [weak self] _ in
                guard let self = self else { return }
                if self.regulator.size.maybeRatio() {
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
        layoutChildren.removeAll(where: { $0.getPresentingView() === subview })
    }

    override open var intrinsicContentSize: CGSize {
        if regulator.size.isRatio() { return .zero }
        if !regulator.size.isRatio() { return sizeThatFits(.zero) }
        if regulator.size.maybeFixed() {
            let height: CGFloat = regulator.size.height.isFixed ? regulator.size.height.fixedValue : 0
            let width: CGFloat = regulator.size.width.isFixed ? regulator.size.width.fixedValue : 0
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
            if regulator.size.bothNotWrap() {
                let layoutResidual = CalculateUtil.getSelfLayoutResidual(for: regulator, fromContentResidual: bounds.size)
                _ = CalHelper.calculateIntrinsicSize(for: regulator, layoutResidual: layoutResidual, strategy: .positive)
            }
        } else {
            var layoutResidual: CGSize
            // 父视图为普通视图
            if control.isSizeControl {
                layoutResidual = CalculateUtil.getInitialLayoutResidual(for: regulator)

                if let spv = superview {
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

                layoutResidual = CalculateUtil.getSelfLayoutResidual(for: regulator, fromContentResidual: bounds.size)
                regulator.calculatedSize = CalHelper.calculateIntrinsicSize(for: regulator, layoutResidual: layoutResidual, strategy: .lazy)
            }

            if control.isCenterControl {
                let b = CGRect(origin: .zero, size: regulator.calculatedSize)
                regulator.calculatedCenter = CGPoint(x: b.midX + regulator.margin.left, y: b.midY + regulator.margin.top)
            }

            if control.isScrollViewControl, let superview = superview as? UIScrollView {
                control(scrollView: superview)
            }

            let animator = py_animator ?? Animators.inherited

            animator.animate(self, size: regulator.calculatedSize, center: regulator.calculatedCenter) {
                if self.control.isSizeControl {
                    self.bounds.size = self.regulator.calculatedSize
                }
                if self.control.isCenterControl {
                    self.center = self.regulator.calculatedCenter
                }
            }

            if regulator.size.bothNotWrap() {
                // 非包裹，必须获取当前尺寸后再次布局子系统
                _ = CalHelper.calculateIntrinsicSize(for: regulator, layoutResidual: layoutResidual, strategy: .positive)
            }
        }

        // 获取最近的animator
        let animator = py_animator ?? getInheritedBoxAnimator(self) ?? Animators.inherited
        // 处理子节点的位置和大小

        // 处理虚拟节点的center
        fixVirtualGroupCenter()

        // 实际赋值位置大小
        subviews.forEach { v in
            if v.py_measure.activated {
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
        let newSize = regulator.calculatedSize
        // 控制父视图的scroll
        if regulator.size.width.isWrap {
            scrollView.contentSize.width = newSize.width + regulator.margin.left + regulator.margin.right
        }
        if regulator.size.height.isWrap {
            scrollView.contentSize.height = newSize.height + regulator.margin.bottom + regulator.margin.top
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
        let measure = subView.py_measure

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
                node.fixChildrenCenterByHostView()
            }
        }
    }

    // MARK: - ViewParasitable

    public func addParasite(_ parasite: UIView) {
        super.addSubview(parasite)
    }

    public func removeParasite(_ parasite: UIView) {
        subviews.first(where: { $0 === parasite })?.removeFromSuperview()
    }

    // MARK: - BoxLayoutContainer

    public var layoutRegulator: Regulator { regulator }

    public var layoutChildren: [BoxLayoutNode] = []

    // MARK: - MeasureChildrenDelegate

    public func children(for _: Measure) -> [Measure] {
        layoutChildren.filter {
            if !$0.layoutNodeType.isVirtual {
                return $0.getPresentingView()?.superview == self
            }
            return true
        }.map(\.layoutMeasure)
    }
}
