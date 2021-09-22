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
    /// Animation can be nested, if you want a specify animation, make sure override the inheritedOptions,
    /// see [UIView.AnimationOptions.overrideInheritedDuration, .overrideInherited*]
    func animate(_ delegate: MeasureDelegate, size: CGSize, center: CGPoint, animations: @escaping () -> Void)
}

public extension Animator {
    func runAsNoneAnimation(_ action: @escaping () -> Void) {
        if isNestedAnimation {
            UIView.animate(withDuration: 0, delay: 0, options: [.curveLinear, .overrideInheritedCurve, .overrideInheritedDuration], animations: action, completion: nil)
        } else {
            action()
        }
    }

    var isNestedAnimation: Bool {
        CATransaction.animationDuration() > 0
    }
}

public enum Animators {
    /// no animation
    public static let none: Animator = NonAnimator()

    /// default animation
    public static let `default`: Animator = `default`()

    public static func `default`(duration: TimeInterval = 0.3, inherited: Bool = false) -> Animator {
        DefaultAnimator(duration: duration, inherited: inherited)
    }

    struct NonAnimator: Animator {
        var duration: TimeInterval = 0
        func animate(_ delegate: MeasureDelegate, size: CGSize, center: CGPoint, animations: @escaping () -> Void) {
            animations()
        }
    }

    struct DefaultAnimator: Animator {
        var duration: TimeInterval
        var inherited: Bool = false
        func animate(_ delegate: MeasureDelegate, size: CGSize, center: CGPoint, animations: @escaping () -> Void) {
            var options: [UIView.AnimationOptions] = [.curveEaseOut]
            if !inherited {
                options.append(contentsOf: [.overrideInheritedDuration, .overrideInheritedCurve, .overrideInheritedOptions])
            }

            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 5, options: .init(options), animations: animations, completion: nil)
        }
    }
}
