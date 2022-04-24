//
//  BoxView.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import UIKit

public protocol RegulatorView {
    func createRegulator() -> Regulator
}

open class BoxView<RegulatorType: Regulator>: UIView, Boxable, RegulatorView, MeasureChildrenDelegate {
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
            control.setNeedsLayout(view: self, regulator: regulator)

            super.setNeedsLayout()

            if regulator.size.maybeWrap() {
                invalidateIntrinsicContentSize()
            }
        }
    }

    /// If subviews.count == 0, will not call layoutSubviews, provide a dummy view to avoid it
    private lazy var dummyView = _DummyView().attach().activated(false).view

    /// indicate if view is calling method layoutSubviews()
    private var layouting = false

    override open func layoutSubviews() {
        if layouting { return }
        layouting = true

        control.layoutSubviews(for: self, regulator: regulator)

        initializing = false
        layouting = false
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
        return control.sizeThatFits(size, regulator: regulator)
    }

    override open func didMoveToSuperview() {
        control.didMoveToSuperview(view: self, regulator: regulator)
        if subviews.isEmpty {
            addSubview(dummyView)
        }
    }

    override open func willRemoveSubview(_ subview: UIView) {
        let count = subviews.count
        if count == 1, subview != dummyView, dummyView.superview == nil {
            // 避免box一个子view都没有
            addSubview(dummyView)
        }
        super.willRemoveSubview(subview)
    }

    override open func addSubview(_ view: UIView) {
        super.addSubview(view)
        if view != dummyView {
            dummyView.removeFromSuperview()
        }
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

    // MARK: - MeasureChildrenDelegate

    public func children(for _: Measure) -> [Measure] {
        subviews.map(\.py_measure)
    }
}

private class _DummyView: UIView {}
