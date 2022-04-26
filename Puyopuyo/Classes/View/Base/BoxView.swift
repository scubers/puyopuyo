//
//  BoxView.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import UIKit

public protocol RegulatorView {
    func createRegulator() -> Regulator

    func addLayoutNode(_ node: BoxLayoutNode)
}

open class BoxView<RegulatorType: Regulator>: UIView, Boxable, RegulatorView, MeasureChildrenDelegate, BoxLayoutContainer, ViewParasitable {
    public var control = BoxControl<RegulatorType>()

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
        if !initializing, !layouting {
            // 若自身可能为包裹，则需要通知上层重新布局
            if regulator.size.maybeWrap(), let superview = superview, BoxUtil.isBox(superview) {
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

    func _layoutSubviews() {
        // 父视图为布局
        if BoxUtil.isBox(superview) {
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

        fixChildrenCenterByHostView()

        subviews.forEach { v in
            if v.py_measure.activated {
                self.applyViewPosition(v, inheritedAnimator: animator)
            }
        }

        // 更新边线
        _updatingBorders()
    }

    func _updatingBorders() {
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

    override open func layoutIfNeeded() {
        if let spv = superview,
           BoxUtil.isBox(spv),
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

    private var positionControlDisposable: Disposer?

    override open func didMoveToSuperview() {
        positionControlDisposable?.dispose()
        if control.isCenterControl, let spv = superview, !BoxUtil.isBox(spv) {
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
        layoutChildren.removeAll(where: { $0.presentingView === subview })
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

    // MARK: - ViewParasitable

    public func addParasite(_ parasite: UIView) {
        super.addSubview(parasite)
    }

    // MARK: - BoxLayoutContainer

    public var hostView: ViewParasitable? {
        get { self }
        set {}
    }

    public var layoutRegulator: Regulator { regulator }

    public var layoutChildren: [BoxLayoutNode] = []

    public func addLayoutNode(_ node: BoxLayoutNode) {
        layoutChildren.append(node)
        if let view = node.presentingView {
            // 只能调用父类方法，避免和 addSubview冲突
            super.addSubview(view)
        }
    }

    public func fixChildrenCenterByHostView() {
        layoutChildren.forEach { node in
            if let node = node as? BoxLayoutContainer, !node.isSelfCoordinate {
                node.fixChildrenCenterByHostView()
            }
        }
    }

    // MARK: - MeasureChildrenDelegate

    public func children(for _: Measure) -> [Measure] {
        layoutChildren.filter {
            if $0.isSelfCoordinate {
                return $0.presentingView?.superview == self
            }
            return true
        }.map(\.layoutMeasure)
    }
}

public protocol BoxLayoutable: AnyObject {
    associatedtype RegulatorType: Regulator
    var boxRegulator: RegulatorType { get }
}

extension BoxView: BoxLayoutable {
    public var boxRegulator: RegulatorType { regulator }
}

/// 布局节点
public protocol BoxLayoutNode: AnyObject {
    var layoutMeasure: Measure { get }
    var presentingView: UIView? { get }
}

public protocol ViewParasitable: AnyObject {
    func addParasite(_ parasite: UIView)
    func setNeedsLayout()
}

///
/// 具备布局能力
public protocol BoxLayoutContainer: BoxLayoutNode, ViewParasitable {
    /// 被子节点寄生的view -> parasiticView.addSubview()
    var hostView: ViewParasitable? { get set }

    var layoutRegulator: Regulator { get }

    var layoutChildren: [BoxLayoutNode] { get }

    func addLayoutNode(_ node: BoxLayoutNode)

    func fixChildrenCenterByHostView()
}

public extension BoxLayoutNode {
    var isSelfCoordinate: Bool { presentingView != nil }
}

extension UIView: BoxLayoutNode {
    public var layoutMeasure: Measure { py_measure }
    public var presentingView: UIView? { self }
}

public class VirtualGroup<R: Regulator>: BoxLayoutContainer, MeasureChildrenDelegate, MeasureDelegate, BoxLayoutable, AutoDisposable {
    public init() {}
    private let bag = NSObject()
    public func addDisposer(_ disposer: Disposer, for key: String?) {
        bag.addDisposer(disposer, for: key)
    }

    public var boxRegulator: R { layoutRegulator as! R }

    public weak var hostView: ViewParasitable?

    public lazy var layoutRegulator: Regulator = createRegulator()

    public func addLayoutNode(_ node: BoxLayoutNode) {
        guard let hostView = hostView else {
            fatalError()
        }

        layoutChildren.append(node)
        if let view = node.presentingView {
            hostView.addParasite(view)
        }
    }

    public var layoutChildren: [BoxLayoutNode] = []

    public var layoutMeasure: Measure { layoutRegulator }

    public var presentingView: UIView? { nil }

    public func fixChildrenCenterByHostView() {
        let center = layoutRegulator.calculatedCenter
        let size = layoutRegulator.calculatedSize

        // 计算虚拟位置的偏移量
        let delta = CGPoint(x: center.x - size.width / 2, y: center.y - size.height / 2)

        layoutChildren.forEach { node in
            var center = node.layoutMeasure.calculatedCenter
            center.x += delta.x
            center.y += delta.y
            node.layoutMeasure.calculatedCenter = center

            if let node = node as? BoxLayoutContainer, !node.isSelfCoordinate {
                node.fixChildrenCenterByHostView()
            }
        }
    }

    public func addParasite(_ parasite: UIView) {
        hostView?.addParasite(parasite)
    }

    public func setNeedsLayout() {
        hostView?.setNeedsLayout()
    }

    public func children(for _: Measure) -> [Measure] {
        layoutChildren.filter { node in
            if let presentingView = node.presentingView {
                return presentingView.superview === hostView
            }
            return true
        }.map(\.layoutMeasure)
    }

    public func needsRelayout(for _: Measure) {
        hostView?.setNeedsLayout()
    }

    public func createRegulator() -> RegulatorType {
        fatalError()
    }
}

public class LinearGroup: VirtualGroup<LinearRegulator> {
    class Regulator: LinearRegulator {
        override func createCalculator() -> Calculator {
            LinearCalculator(estimateChildren: false)
        }
    }

    override public func createRegulator() -> VirtualGroup<LinearRegulator>.RegulatorType {
        Regulator(delegate: self, sizeDelegate: nil, childrenDelegate: self)
    }
}

public class FlowGroup: VirtualGroup<FlowRegulator> {
    override public func createRegulator() -> VirtualGroup<FlowRegulator>.RegulatorType {
        FlowRegulator(delegate: self, sizeDelegate: nil, childrenDelegate: self)
    }
}
