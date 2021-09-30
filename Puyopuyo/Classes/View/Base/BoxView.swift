//
//  BoxView.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

open class BoxView<RegulatorType: Regulator>: UIView, Boxable {
    public var control = BoxControl<RegulatorType>()

    public var regulator: RegulatorType { py_measure as! RegulatorType }

    // MARK: - init

    override public init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(dummyView)
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
        }
    }

    /// If subviews.count == 0, will not call layoutSubviews, provide a dummy view to avoid it
    private let dummyView = UIView().attach().activated(false).view

    override open func didAddSubview(_ subview: UIView) {
        if subview != dummyView, dummyView.superview == nil {
            addSubview(dummyView)
        }
    }

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
        if BoxUtil.isBox(superview), regulator.size.maybeWrap() {
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
    }
}
