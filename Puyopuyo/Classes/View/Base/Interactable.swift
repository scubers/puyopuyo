//
//  Interactable.swift
//  Puyopuyo
//
//  Created by J on 2021/9/14.
//

import Foundation

// MARK: - Stateful

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

// MARK: - Eventable

public protocol Eventable {
    associatedtype EventType
    var eventProducer: SimpleIO<EventType> { get }
}

public extension Eventable {
    func emmit(_ event: EventType) {
        eventProducer.input(value: event)
    }
}

// MARK: - Animator

public protocol Animator {
    func animate(_ delegate: MeasureDelegate, size: CGSize, center: CGPoint, animations: @escaping () -> Void)
}

public enum Animators {
    /// no animation
    public static let none: Animator = NonAnimator()

    /// default animation
    public static let `default`: Animator = DefaultAnimator()

    struct NonAnimator: Animator {
        func animate(_ delegate: MeasureDelegate, size: CGSize, center: CGPoint, animations: @escaping () -> Void) {
            animations()
        }
    }

    struct DefaultAnimator: Animator {
        func animate(_ delegate: MeasureDelegate, size: CGSize, center: CGPoint, animations: @escaping () -> Void) {
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 5, options: .curveEaseOut, animations: animations, completion: nil)
        }
    }
}

public struct ExpandAnimator: Animator {
    public init() {}
    public func animate(_ delegate: MeasureDelegate, size: CGSize, center: CGPoint, animations: @escaping () -> Void) {
        let realSize = delegate.py_size
        let realCenter = delegate.py_center
        let view = delegate as? UIView
        if realSize != size || realCenter != center {
            CATransaction.begin()
            if realSize == .zero, realCenter == .zero {
                // 第一次布局，center赋值
                delegate.py_center = center
                delegate.py_size = CGSize(width: size.width * 0.9, height: size.height * 0.9)
                view?.layer.transform = CATransform3DMakeRotation(.pi / 8, 0, 0, 1)
            }

            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 5, options: [.curveEaseOut, .beginFromCurrentState, .transitionCrossDissolve, .overrideInheritedDuration], animations: {
                animations()
                view?.layer.transform = CATransform3DIdentity
            }, completion: nil)
            CATransaction.commit()
        } else {
            animations()
        }
    }
}
