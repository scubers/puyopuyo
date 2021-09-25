//
//  Animator.swift
//  Puyopuyo
//
//  Created by J on 2021/9/22.
//

import Foundation

// MARK: - Animator

public protocol Animator {
    var duration: TimeInterval { get }
    /// Animation can be nested, if you want a specify animation, make sure override the inheritedOptions,
    /// see [UIView.AnimationOptions.overrideInheritedDuration, .overrideInherited*]
    func animate(_ delegate: MeasureDelegate, size: CGSize, center: CGPoint, animations: @escaping () -> Void)
}

public extension Animator {
    func runAsNoneAnimation(_ action: @escaping () -> Void) {
        UIView.performWithoutAnimation(action)
//        if isNestedAnimation {
//
//            UIView.animate(withDuration: 0, delay: 0, options: [.curveLinear, .overrideInheritedCurve, .overrideInheritedDuration], animations: action, completion: nil)
//        } else {
//            action()
//        }
    }

    var isNestedAnimation: Bool {
        CATransaction.animationDuration() > 0
    }
}

public enum Animators {
    /// inherited animation
    public static let inherited: Animator = InheritedAnimator()

    public static let none: Animator = NoneAnimator()

    /// default animation
    public static let `default`: Animator = `default`()

    public static func `default`(duration: TimeInterval = 0.3, inherited: Bool = false) -> Animator {
        DefaultAnimator(duration: duration, inherited: inherited)
    }

    struct NoneAnimator: Animator {
        var duration: TimeInterval = 0
        func animate(_ delegate: MeasureDelegate, size: CGSize, center: CGPoint, animations: @escaping () -> Void) {
            UIView.performWithoutAnimation(animations)
        }
    }

    struct InheritedAnimator: Animator {
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
