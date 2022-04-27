//
//  ControlPad.swift
//  Puyopuyo_Example
//
//  Created by J on 2021/9/17.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

import Puyopuyo

class ControlPad: UIView, Stateful, Eventable {
    struct ViewState {
        var x: CGFloat
        var y: CGFloat
    }

    var emitter = SimpleIO<ViewState>()
    var state = State(ViewState(x: 0.5, y: 0.5))

    override init(frame: CGRect) {
        super.init(frame: frame)

        attach {
            let w: CGFloat = 30
            UIView().attach($0) {
                let pan = UIPanGestureRecognizer()
                pan.py_addAction { [weak self] g in
                    guard let self = self else { return }
                    let pan = g as! UIPanGestureRecognizer
                    let point = pan.translation(in: self)
                    let deltaX = point.x / self.frame.width
                    let deltaY = point.y / self.frame.height
                    pan.setTranslation(.zero, in: self)
                    let p = CGPoint(x: self.state.value.x + deltaX, y: self.state.value.y + deltaY)
                    self.state.value = .init(x: max(0, min(1, p.x)), y: max(0, min(1, p.y)))

                    self.emit(self.state.value)
                }
                $0.addGestureRecognizer(pan)
            }
            .style(ShadowStyle())
            .activated(false)
            .backgroundColor(UIColor.black)
            .cornerRadius(w / 2)
            .frame(
                Outputs.combine(py_boundsState(), binder)
                    .map { rect, point -> CGRect in
                        let x = (rect.width - w) * point.x
                        let y = (rect.height - w) * point.y
                        return CGRect(x: x, y: y, width: w, height: w)
                    }
                    .distinct()
            )
        }
        .cornerRadius(8)
        .backgroundColor(UIColor.lightGray.withAlphaComponent(0.7))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    deinit {
        print("control pad deinit")
    }
}
