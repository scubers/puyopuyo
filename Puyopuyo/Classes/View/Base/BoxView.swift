//
//  BoxView.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import UIKit

// MARK: - BoxControl

public class BoxControl {}

public protocol RegulatorSpecifier: AnyObject {
    associatedtype RegulatorType: Regulator
    var regulator: RegulatorType { get }
}

public extension UIView {
    var isBoxView: Bool { self is BoxView }
}

// MARK: - BoxView

open class BoxView: UIView, MeasureChildrenDelegate, BoxLayoutContainer, ViewParasitizing {
    public struct RootBoxConfig {
        public enum ControlType {
            case bySet
            case byCalculate

            var isCalculate: Bool { self == .byCalculate }
        }

        public var sizeControl = ControlType.byCalculate

        public var centerControl = ControlType.byCalculate
        ///
        /// Control `contentSize` when superview is UIScrollView
        public var isScrollViewControl = false
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

    // MARK: - Open method

    public var borders = Borders()

    public var rootBoxConfig = RootBoxConfig()

    /// override this method to build custom view in subclass
    open func buildBody() {}

    open func createRegulator() -> Regulator {
        fatalError("subclass impl")
    }

    // MARK: - Public method

    public var isRootBox: Bool {
        !layoutRegulator.activated || (superview == nil) || !(superview is BoxView)
    }

    // MARK: - Overrides

    /// when layout once it will be false
    private var initializing = true

    override open func setNeedsLayout() {
        if !initializing {
            // 若自身可能为包裹，则需要通知上层重新布局
            if layoutRegulator.size.maybeWrap, let superview = superview, superview.isBoxView {
                superview.setNeedsLayout()
            }

            super.setNeedsLayout()

            if layoutRegulator.size.maybeWrap {
                invalidateIntrinsicContentSize()
            }
        }
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        _layoutSubviews()
        initializing = false
    }

    override open func layoutIfNeeded() {
        if !isRootBox, layoutRegulator.size.maybeWrap {
            // 需要父布局进行计算
            superview?.layoutIfNeeded()
        } else {
            super.layoutIfNeeded()
        }
    }

    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        return IntrinsicSizeHelper.sizeThatFit(size: size, to: layoutRegulator)
    }

    override open func didMoveToSuperview() {
        positionControlDisposable?.dispose()
        if rootBoxConfig.sizeControl.isCalculate, let spv = superview, !spv.isBoxView {
            let boundsSize = spv
                .py_observing(\.bounds)
                .map(\.size, .zero)

            positionControlDisposable = boundsSize.distinct().outputing { [weak self] _ in
                guard let self = self else { return }
                if self.layoutRegulator.size.maybeRatio {
                    self.setNeedsLayout()
                }
            }
        }
    }

    override open func addSubview(_ view: UIView) {
        addLayoutNode(view)
    }

    override public func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)
        willRemoveParasite(subview)
        if !isRemovingParasite {
            subview.superBox?.layoutChildren.removeAll(where: { $0.layoutNodeView === subview })
            subview.superBox = nil
        }
    }

    open func willRemoveParasite(_: ViewDisplayable) {}

    override open var intrinsicContentSize: CGSize {
        if layoutRegulator.size.isRatio { return .zero }
        if !layoutRegulator.size.isRatio { return sizeThatFits(.zero) }
        if layoutRegulator.size.maybeFixed {
            let height: CGFloat = layoutRegulator.size.height.isFixed ? layoutRegulator.size.height.fixedValue : 0
            let width: CGFloat = layoutRegulator.size.width.isFixed ? layoutRegulator.size.width.fixedValue : 0
            return CGSize(width: width, height: height)
        }
        return .zero
    }

    // MARK: Private methods

    private var positionControlDisposable: Disposer?

    private func _layoutSubviews() {
        guard layoutVisibility != .gone else {
            // gone 不用计算
            return
        }

        if !isRootBox {
            /**
             1. 当父布局为Box视图，并且当前布局可能是包裹，则视为被上层计算时优先计算过了。当前视图可不用重复计算
             2. 若非包裹，则上层视图时只是用了估算尺寸，需要再次计算子节点
             */
            if layoutRegulator.size.bothNotWrap, layoutVisibility == .visible {
                let layoutResidual = ResidualHelper.getSelfLayoutResidual(for: layoutRegulator, fromContentResidual: bounds.size)
                _ = IntrinsicSizeHelper.calculateIntrinsicSize(for: layoutRegulator, layoutResidual: layoutResidual, strategy: .calculate)
            }
        } else {
            var layoutResidual: CGSize

            switch rootBoxConfig.sizeControl {
            case .bySet:
                layoutResidual = ResidualHelper.getInitialLayoutResidual(for: layoutRegulator, contentConstraint: bounds.size)
            case .byCalculate:
                layoutResidual = ResidualHelper.getInitialLayoutResidual(for: layoutRegulator)
                let superviewSize = superview?.bounds.size ?? .zero
                if layoutRegulator.size.width.isRatio { layoutResidual.width = superviewSize.width }
                if layoutRegulator.size.height.isRatio { layoutResidual.height = superviewSize.height }
            }

            let size = IntrinsicSizeHelper.calculateIntrinsicSize(for: layoutRegulator, layoutResidual: layoutResidual, strategy: .calculate)
            layoutRegulator.calculatedSize = size

            layoutRegulator.calculatedCenter = CGPoint(
                x: size.width / 2 + layoutRegulator.margin.left,
                y: size.height / 2 + layoutRegulator.margin.top
            )

            controlScrollViewIfNeeded()

            controlPositionAndSizeIfNeeded()
        }

        // 处理子节点的位置和大小
        let animator = py_animator ?? getInheritedBoxAnimator(self) ?? Animators.inherited
        layoutChildren.forEach {
            $0.applyConcreteNodePosition(with: .zero, superAnimator: animator)
        }

        // 更新边线
        updatingBorders()
    }

    private func updatingBorders() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        borders.updateTop(to: layer)
        borders.updateLeft(to: layer)
        borders.updateBottom(to: layer)
        borders.updateRight(to: layer)
        CATransaction.commit()
    }

    private func controlPositionAndSizeIfNeeded() {
        if rootBoxConfig.sizeControl.isCalculate || rootBoxConfig.centerControl.isCalculate {
            let animator = py_animator ?? Animators.inherited
            animator.animate(self, size: layoutRegulator.calculatedSize, center: layoutRegulator.calculatedCenter) {
                if self.rootBoxConfig.sizeControl.isCalculate {
                    self.bounds.size = self.layoutRegulator.calculatedSize
                }
                if self.rootBoxConfig.centerControl.isCalculate {
                    self.center = self.layoutRegulator.calculatedCenter
                }
            }
        }
    }

    /// 处理superview 是scrollView的情况，控制其 contentSize
    private func controlScrollViewIfNeeded() {
        guard let scrollView = superview as? UIScrollView, rootBoxConfig.isScrollViewControl else {
            return
        }

        let size = layoutRegulator.calculatedSize
        // 控制父视图的scroll
        if layoutRegulator.size.width.isWrap {
            scrollView.contentSize.width = size.width + layoutRegulator.margin.getHorzTotal()
        }
        if layoutRegulator.size.height.isWrap {
            scrollView.contentSize.height = size.height + layoutRegulator.margin.getVertTotal()
        }
    }

    private func getInheritedBoxAnimator(_ view: UIView?) -> Animator? {
        if let animator = view?.py_animator {
            return animator
        } else if view?.superview?.isBoxView ?? false {
            return getInheritedBoxAnimator(view?.superview)
        } else {
            return nil
        }
    }

    // MARK: - ViewParasitizing

    open func addParasite(_ parasite: ViewDisplayable) {
        super.addSubview(parasite.dislplayView)
    }

    private var isRemovingParasite = false
    open func removeParasite(_ parasite: ViewDisplayable) {
        assert(!isRemovingParasite)
        if parasite.dislplayView.superview == self {
            isRemovingParasite = true
            parasite.dislplayView.removeFromSuperview()
            isRemovingParasite = false
        }
    }

    // MARK: - BoxLayoutContainer

    public var layoutRegulator: Regulator { layoutMeasure as! Regulator }

    public var layoutChildren: [BoxLayoutNode] = []

    open func addLayoutNode(_ node: BoxLayoutNode) {
        _addLayoutNode(node)
    }

    // MARK: - MeasureChildrenDelegate

    public func children(for _: Measure) -> [Measure] {
        layoutChildren.filter {
            if !$0.layoutNodeType.isVirtual {
                return $0.layoutNodeView?.superview == self
            }
            return true
        }.map(\.layoutMeasure)
    }

    public func measureIsLayoutEntry(_: Measure) -> Bool {
        true
    }
}

open class GenericBoxView<R: Regulator>: BoxView, RegulatorSpecifier {
    public var regulator: R { layoutRegulator as! R }
}

extension BoxLayoutNode {
    func applyConcreteNodePosition(with offset: CGPoint, superAnimator: Animator?) {
        // 不处理未激活
        guard layoutMeasure.activated else { return }

        if case .concrete(let view) = layoutNodeType {
            // 具体view则处理位置
            apply(view: view, offset: offset, superAnimator: superAnimator)

        } else if let group = self as? BoxGroup {
            let nextOffset = group.layoutRegulator.calculatedOrigin.add(offset)
            group.layoutChildren.forEach {
                $0.applyConcreteNodePosition(with: nextOffset, superAnimator: superAnimator)
            }
        }
    }

    private func apply(view: UIView, offset: CGPoint, superAnimator: Animator?) {
        let measure = view.layoutMeasure

        let animator = view.py_animator
            ?? superAnimator
            ?? Animators.inherited

        animator.animate(view, size: measure.calculatedSize, center: measure.calculatedCenter) {
            view.bounds.size = measure.calculatedSize
            view.center = measure.calculatedCenter.add(offset)
        }
    }
}
