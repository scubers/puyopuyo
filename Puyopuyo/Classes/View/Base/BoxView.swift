//
//  BoxView.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import UIKit

// MARK: - BoxControl

public class BoxControl {
    public enum ControlType {
        case bySet
        case byCalculate

        var isCalculate: Bool { self == .byCalculate }
    }

    ///
    /// Control `contentSize` when superview is UIScrollView
    public var isScrollViewControl = false

    public var sizeControl = ControlType.byCalculate

    public var centerControl = ControlType.byCalculate

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

open class BoxView: UIView, MeasureChildrenDelegate, BoxLayoutContainer, ViewParasitizing {
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
            if layoutRegulator.size.maybeWrap, let superview = superview, superview.isBoxView {
                superview.setNeedsLayout()
            }

            super.setNeedsLayout()

            if layoutRegulator.size.maybeWrap {
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
           layoutRegulator.size.maybeWrap
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
        if control.sizeControl.isCalculate, let spv = superview, !spv.isBoxView {
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
        if removingParasite == nil {
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
        // 父视图为布局

        if superview?.isBoxView ?? false, layoutRegulator.activated {
            /**
             1. 当父布局为Box视图，并且当前布局可能是包裹，则视为被上层计算时优先计算过了。当前视图可不用重复计算
             2. 若非包裹，则上层视图时只是用了估算尺寸，需要再次计算子节点
             */
            if layoutRegulator.size.bothNotWrap, layoutVisibility == .visible {
                let layoutResidual = CalculateUtil.getSelfLayoutResidual(for: layoutRegulator, fromContentResidual: bounds.size)
                _ = CalHelper.calculateIntrinsicSize(for: layoutRegulator, layoutResidual: layoutResidual, strategy: .calculate)
            }
        } else {
            var layoutResidual: CGSize

            switch control.sizeControl {
            case .bySet:
                layoutResidual = CalculateUtil.getInitialLayoutResidual(for: layoutRegulator, constraint: bounds.size)
            case .byCalculate:
                layoutResidual = CalculateUtil.getInitialLayoutResidual(for: layoutRegulator)
                let superviewSize = superview?.bounds.size ?? .zero
                if layoutRegulator.size.width.isRatio { layoutResidual.width = superviewSize.width }
                if layoutRegulator.size.height.isRatio { layoutResidual.height = superviewSize.height }
            }

            layoutRegulator.calculatedSize = CalHelper.calculateIntrinsicSize(for: layoutRegulator, layoutResidual: layoutResidual, strategy: .calculate)

            let rect = CGRect(origin: .zero, size: layoutRegulator.calculatedSize)
            layoutRegulator.calculatedCenter = CGPoint(
                x: rect.midX + layoutRegulator.margin.left,
                y: rect.midY + layoutRegulator.margin.top
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
        control.borders.updateTop(to: layer)
        control.borders.updateLeft(to: layer)
        control.borders.updateBottom(to: layer)
        control.borders.updateRight(to: layer)
        CATransaction.commit()
    }

    private func controlPositionAndSizeIfNeeded() {
        if control.sizeControl.isCalculate || control.centerControl.isCalculate {
            let animator = py_animator ?? Animators.inherited
            animator.animate(self, size: layoutRegulator.calculatedSize, center: layoutRegulator.calculatedCenter) {
                if self.control.sizeControl.isCalculate {
                    self.bounds.size = self.layoutRegulator.calculatedSize
                }
                if self.control.centerControl.isCalculate {
                    self.center = self.layoutRegulator.calculatedCenter
                }
            }
        }
    }

    /// 处理superview 是scrollView的情况，控制其 contentSize
    private func controlScrollViewIfNeeded() {
        guard let scrollView = superview as? UIScrollView, control.isScrollViewControl else {
            return
        }

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

    // MARK: - ViewParasitizing

    open func addParasite(_ parasite: ViewDisplayable) {
        super.addSubview(parasite.dislplayView)
    }

    private var removingParasite: ViewDisplayable?
    open func removeParasite(_ parasite: ViewDisplayable) {
        assert(removingParasite == nil)
        if parasite.dislplayView.superview == self {
            removingParasite = parasite
            parasite.dislplayView.removeFromSuperview()
            removingParasite = nil
        }
    }

    // MARK: - BoxLayoutContainer

    public var layoutRegulator: Regulator { layoutMeasure as! Regulator }

    public var layoutChildren: [BoxLayoutNode] = []

    public var parasitizingHostForChildren: ViewParasitizing? {
        self
    }

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
