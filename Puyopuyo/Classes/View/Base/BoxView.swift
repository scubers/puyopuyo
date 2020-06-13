//
//  BoxView.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

@available(*, deprecated, message: "use Stateful")
public typealias StatefulView = Stateful

public protocol Stateful {
    associatedtype StateType
    var viewState: State<StateType> { get }
}

public extension Stateful {
    var _state: SimpleOutput<StateType> { viewState.asOutput() }
    func _state<R>(_ kp: KeyPath<StateType, R>) -> SimpleOutput<R> {
        _state.map(kp)
    }

    var binding: StateBinding<StateType> { .init(output: viewState.asOutput()) }
}

@available(*, deprecated, message: "use Eventable")
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

public struct Animators {
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

    public override init(frame: CGRect) {
        super.init(frame: frame)
        buildBody()
    }

    public required init?(coder _: NSCoder) {
        super.init(frame: .zero)
        buildBody()
    }

    open override func addSubview(_ view: UIView) {
        super.addSubview(view)
        boxHelper.setNeedsLayout(view: view, regulator: regulator)
    }

    open override func setNeedsLayout() {
        super.setNeedsLayout()
        boxHelper.setNeedsLayout(view: self, regulator: regulator)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        boxHelper.layoutSubviews(view: self, regulator: regulator)
    }

    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return boxHelper.sizeThatFits(size, regulator: regulator)
    }

    open func buildBody() {}

    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        boxHelper.didMoveToSuperview(view: self, regulator: regulator)
    }
}
