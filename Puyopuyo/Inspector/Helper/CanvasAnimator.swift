//
//  CanvasAnimator.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/5/24.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

class CanvasAnimator: Animator {
    var duration: TimeInterval { 0.25 }

    func animate(_ view: UIView, size: CGSize, center: CGPoint, animations: @escaping () -> Void) {
        if view.bounds == .zero, size != .zero {
            runAsNoneAnimation {
                view.bounds.size = size
                view.center = center
            }
        } else {
            Animators.default.animate(view, size: size, center: center, animations: animations)
        }
    }
}
