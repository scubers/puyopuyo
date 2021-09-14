//
//  BoxView.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

open class BoxView<RegulatorType: Regulator>: UIView, Boxable {
    public var control = BoxControl<RegulatorType>()

    public var regulator: RegulatorType {
        return py_measure as! RegulatorType
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        buildBody()
    }

    public required init?(coder _: NSCoder) {
        super.init(frame: .zero)
        buildBody()
    }

    override open func addSubview(_ view: UIView) {
        super.addSubview(view)
        control.setNeedsLayout(view: view, regulator: regulator)
    }

    private var initializing = true
    private var layouting = false

    override open func setNeedsLayout() {
        if !initializing, !layouting {
            super.setNeedsLayout()
            control.setNeedsLayout(view: self, regulator: regulator)
        }
    }

    override open func layoutSubviews() {
        if layouting { return }
        layouting = true
        super.layoutSubviews()
        control.layoutSubviews(view: self, regulator: regulator)
        initializing = false
        layouting = false
    }

    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        return control.sizeThatFits(size, regulator: regulator)
    }

    open func buildBody() {}

    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        control.didMoveToSuperview(view: self, regulator: regulator)
    }
}

class InspectView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.blue.withAlphaComponent(0.2)
        py_measure.activated = false
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    var superMeasure: Measure?

    var disposer: Disposer?

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        disposer?.dispose()
        superMeasure = superview?.py_measure
        superview?.py_boundsState().safeBind(to: self) { this, rect in
            let margin = this.superMeasure!.margin
            this.frame.size = CGSize(width: rect.width + margin.getHorzTotal(), height: rect.height + margin.getVertTotal())
            this.center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        }
    }
}
