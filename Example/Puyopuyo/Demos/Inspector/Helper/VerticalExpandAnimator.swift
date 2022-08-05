//
//  VerticalExpandAnimator.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/5/23.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

struct VerticalExpandAnimator: Animator {
    var duration: TimeInterval { 0.25 }

    func animate(_ view: UIView, size: CGSize, center: CGPoint, animations: @escaping () -> Void) {
        runAsNoneAnimation {
            view.bounds.size.width = size.width
            view.center.x = center.x
        }

        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 5, options: [], animations: animations, completion: nil)
    }
}
