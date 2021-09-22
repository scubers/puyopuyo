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
    var duration: TimeInterval { get }
    func animate(_ delegate: MeasureDelegate, size: CGSize, center: CGPoint, animations: @escaping () -> Void)
}

public extension Animator {
    func runAsNoneAnimation(_ action: @escaping () -> Void) {
        let d = CATransaction.animationDuration()
        if d > 0 {
            UIView.animate(withDuration: 0, delay: 0, options: [.curveLinear, .overrideInheritedCurve, .overrideInheritedDuration], animations: action, completion: nil)
        } else {
            action()
        }
    }
}

public enum Animators {
    /// no animation
    public static let none: Animator = NonAnimator()

    /// default animation
    public static let `default`: Animator = `default`()
    
    public static func `default`(duration: TimeInterval = 0.3) -> Animator {
        DefaultAnimator(duration: duration)
    }

    struct NonAnimator: Animator {
        var duration: TimeInterval = 0
        func animate(_ delegate: MeasureDelegate, size: CGSize, center: CGPoint, animations: @escaping () -> Void) {
            animations()
        }
    }

    struct DefaultAnimator: Animator {
        var duration: TimeInterval
        func animate(_ delegate: MeasureDelegate, size: CGSize, center: CGPoint, animations: @escaping () -> Void) {
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 5, options: .curveEaseOut, animations: animations, completion: nil)
        }
    }
}

public struct ExpandAnimator: Animator {
    public init(duration: TimeInterval = 0.3) {
        self.duration = duration
    }

    public var duration: TimeInterval
    public func animate(_ delegate: MeasureDelegate, size: CGSize, center: CGPoint, animations: @escaping () -> Void) {
        let realSize = delegate.py_size
        let realCenter = delegate.py_center
        let view = delegate as? UIView
        if realSize != size || realCenter != center {
            CATransaction.begin()
            if realSize == .zero, realCenter == .zero {
                // 第一次布局，center赋值
                runAsNoneAnimation {
                    delegate.py_center = center
                    delegate.py_size = CGSize(width: size.width * 0.9, height: size.height * 0.9)
                    view?.layer.transform = CATransform3DMakeRotation(.pi / 8, 0, 0, 1)
                }
            }

            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 5, options: [.curveEaseOut, .beginFromCurrentState, .transitionCrossDissolve, .overrideInheritedDuration], animations: {
                animations()
                if realSize == .zero, realCenter == .zero {
                    view?.layer.transform = CATransform3DIdentity
                }

            }, completion: nil)
            CATransaction.commit()
        } else {
            animations()
        }
    }
}
