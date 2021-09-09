//
//  BoxView.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

@available(*, deprecated, message: "@see Stateful")
public typealias StatefulView = Stateful

public protocol Stateful {
    associatedtype StateType
    var viewState: State<StateType> { get }
}

public extension Stateful {
    var output: Outputs<StateType> { viewState.asOutput() }

    func bind<R>(_ keyPath: KeyPath<StateType, R>) -> Outputs<R> {
        output.map(keyPath)
    }

    var _state: Outputs<StateType> { output }
}

@available(*, deprecated, message: "@see Eventable")
public typealias EventableView = Eventable
public protocol Eventable {
    associatedtype EventType
    var eventProducer: SimpleIO<EventType> { get }
}

public extension Eventable {
    func emmit(_ event: EventType) {
        eventProducer.input(value: event)
    }
}

public protocol Animator {
    func animate(view: UIView, layouting: @escaping () -> Void)
}

public enum Animators {
    /// no animation
    public static let none: Animator = NonAnimator()

    /// default animation
    public static let `default`: Animator = DefaultAnimator()

    struct NonAnimator: Animator {
        public func animate(view _: UIView, layouting: @escaping () -> Void) {
            layouting()
        }
    }

    struct DefaultAnimator: Animator {
        func animate(view _: UIView, layouting: @escaping () -> Void) {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 5, options: .curveEaseOut, animations: layouting, completion: nil)
        }
    }
}

open class BoxView<RegulatorType: Regulator>: UIView, Boxable {
    public var boxHelper = BoxHelper<RegulatorType>()

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
        boxHelper.setNeedsLayout(view: view, regulator: regulator)
    }

    private var initializing = true
    private var layouting = false

    override open func setNeedsLayout() {
        if !initializing && !layouting {
            super.setNeedsLayout()
            boxHelper.setNeedsLayout(view: self, regulator: regulator)
        }
    }

    override open func layoutSubviews() {
        if layouting { return }
        layouting = true
        super.layoutSubviews()
        boxHelper.layoutSubviews(view: self, regulator: regulator)
        initializing = false
        layouting = false
    }

    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        return boxHelper.sizeThatFits(size, regulator: regulator)
    }

    open func buildBody() {}

    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        boxHelper.didMoveToSuperview(view: self, regulator: regulator)
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
