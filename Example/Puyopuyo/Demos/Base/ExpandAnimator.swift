//
//  ExpandAnimator.swift
//  Puyopuyo_Example
//
//  Created by J on 2021/9/22.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import Puyopuyo

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
            if realSize == .zero, realCenter == .zero {
                // 第一次布局，center赋值
                runAsNoneAnimation {
                    delegate.py_center = center
                    let scale: CGFloat = 0.5
                    delegate.py_size = CGSize(width: size.width * scale, height: size.height * scale)
                    view?.layer.transform = CATransform3DMakeRotation(.pi / 8 + .pi, 0, 0, 1)
                }
            }

            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 5, options: [.curveEaseOut, .overrideInheritedOptions, .overrideInheritedDuration], animations: {
                animations()
                if realSize == .zero, realCenter == .zero {
                    view?.layer.transform = CATransform3DIdentity
                }
            }, completion: nil)
        } else {
            animations()
        }
    }
}

struct SpinAnimator: Animator {
    var duration: TimeInterval { 0.5 }

    func animate(_ delegate: MeasureDelegate, size: CGSize, center: CGPoint, animations: @escaping () -> Void) {
        let isZero = delegate.isZero
        let view = delegate as? UIView
        if isZero {
            runAsNoneAnimation {
                delegate.py_center = center
                delegate.py_size = size
                view?.layer.transform = CATransform3DMakeRotation(.pi / 2, 0, 1, 0)
            }
        }

        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 5, options: [.curveEaseOut, .overrideInheritedOptions, .overrideInheritedDuration], animations: {
            animations()
            if isZero {
                view?.layer.transform = CATransform3DIdentity
            }
        }, completion: nil)
    }
}
