//
//  BoxView.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

public protocol StatefulView {
    associatedtype StateType
    var viewState: State<StateType> { get }
}

public protocol EventableView {
    associatedtype EventType
    var eventProducer: SimpleIO<EventType> { get }
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

open class BoxView<R: Regulator>: UIView, Boxable {
    public var boxHelper = BoxHelper<R>()

    public var regulator: R {
        return py_measure as! R
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        buildBody()
    }

    public required init?(coder _: NSCoder) {
        super.init(frame: .zero)
        buildBody()
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
