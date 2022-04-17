//
//  AnimationVC.swift
//  Puyopuyo_Example
//
//  Created by J on 2021/9/22.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import Puyopuyo
import UIKit

class AnimationVC: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        DemoScroll {
            UILabel().attach($0)
                .fontSize(20, weight: .bold)
                .text("""
                There 2 ways to animate views.
                1. After setting properties (size or position sensitive) to view, call view.layoutIfNeeded() in a animation transaction
                    UIView.animate(duration: 0.25) {
                        view.layoutIfNeeded()
                    }

                2. There is some size or position insensitive properties, will effect immediately after set.
                    For example: alpha, color....
                    Use animation block to set value

                    UIView.animate(duration: 0.25) {
                        state.input(value: UIColor.black)
                    }

                3. UIView has a extension properties UIView.py_animator which conforms to Animator protocol.
                - Will create animation for each view if needed.
                - If view's animator is nil, will use parent's animator, parent must be BoxView
                """)
                .numberOfLines(0)

            controlWillAppearAnimation().attach($0)

            layoutIfNeededDemo().attach($0)

            sizeInsensitiveAnimation().attach($0)

            buildInAnimation().attach($0)
        }
        .attach(view)
        .size(.fill, .fill)
    }

    func controlWillAppearAnimation() -> UIView {
        let elements = State<[Int]>((0 ..< 3).map { $0 })
        let reverse = State(false)

        func increase() {
            elements.value.append(elements.value.count)
        }
        return DemoView<Int>(
            title: "Will appear animation",
            builder: {
                VFlowBuilder<Int>(items: elements.asOutput()) { o, _ in
                    Label.demo("").attach()
                        .size(50, 50)
                        .text(o.data.map { v -> String in
                            if v == 0 { return "Click" }
                            else { return v.description }
                        })
                        .animator(ExpandAnimator())
                        .view
                }
                .attach($0)
                .reverse(reverse)
                .space(4)
                .demo()
                .width(.fill)
                .padding(all: 10)
                .onTap(increase)

            },
            selectors: [],
            desc: """
            Implement protocol Animators to control your view's animation.
            Detail see [ExpandAnimator]
            """
        )
        .attach()
        .width(.fill)
        .view
    }

    func buildInAnimation() -> UIView {
        let format = State(Format.leading)
        return DemoView<Format>(
            title: "Buildin animation",
            builder: {
                HBox().attach($0) {
                    Label.demo(".none").attach($0)
                        .animator(Animators.none)

                    Label.demo("nil").attach($0)

                    Label.demo("custom").attach($0)
                        .animator(Animators.default(duration: 2))
                }
                .space(4)
                .demo()
                .animator(Animators.default)
                .format(format)
                .justifyContent(.center)
                .width(.fill)
                .padding(all: 10)
            },
            selectors: Format.allCases.map { f in
                Selector(desc: "\(f)", value: f)
            },
            selected: format.value,
            desc: """
            .none: Will not animated
            nil: Use the parent BoxView's animation
            custom: Custom animation
            """
        )
        .attach()
        .onEvent(format)
        .width(.fill)
        .view
    }

    func sizeInsensitiveAnimation() -> UIView {
        let color = State(UIColor.systemGreen)
        return DemoView<UIColor>(
            title: "Size insensitive animation",
            builder: {
                HBox().attach($0) {
                    for _ in 0 ..< 3 {
                        UIView().attach($0)
                            .size(50, 50)
                            .backgroundColor(color)
                    }
                }
                .space(4)
                .demo()
                .animator(nil)
                .format(.center)
                .justifyContent(.center)
                .width(.fill)
                .padding(all: 10)
            },
            selectors: [
                Selector(desc: "pink", value: UIColor.systemPink),
                Selector(desc: "blue", value: UIColor.systemBlue),
                Selector(desc: "green", value: UIColor.systemGreen),
            ],
            selected: color.value
        )
        .attach()
        .onEvent { c in
            UIView.animate(withDuration: 0.5) {
                color.input(value: c)
            }
        }
        .width(.fill)
        .animator(Animators.inherited)
        .view
    }

    func layoutIfNeededDemo() -> UIView {
        var boxView: UIView?
        let format = State(Format.leading)
        return DemoView<Format>(
            title: "view.layoutIfNeeded()",
            builder: {
                boxView = HBox().attach($0) {
                    for _ in 0 ..< 3 {
                        Label.demo("").attach($0)
                            .size(50, 50)
                    }
                }
                .space(4)
                .demo()
                .animator(nil)
                .format(format)
                .justifyContent(.center)
                .width(.fill)
                .padding(all: 10)
                .view
            },
            selectors: Format.allCases.map { f in
                Selector(desc: "\(f)", value: f)
            },
            selected: format.value
        )
        .attach()
        .onEvent {
            format.input(value: $0)
            UIView.animate(withDuration: 0.2) {
                boxView?.layoutIfNeeded()
            }
        }
        .width(.fill)
        .animator(Animators.inherited)
        .view
    }
}
