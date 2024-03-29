//
//  NavigationBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/15.
//

import UIKit

open class NavigationBox: VBox, Stateful {
    public struct ViewState {
        public init() {}
        public var visible: Visibility = .visible
        public var navOffset = CGPoint.zero
        public var bodyAvoidNavBar = true
        public var backgroundColor: UIColor = .white
        public var animator: Animator? = Animators.default
        public var alpha: CGFloat = 1
        public var shadowOffset = CGSize(width: 0, height: 1)
        public var shadowColor: UIColor? = UIColor.lightGray.withAlphaComponent(0.5)
        public var shadowOpacity: Float = 0
        public var shadowRadius: CGFloat = 0
    }

    public var state = State(ViewState())

    public init(navBar: BoxGenerator<UIView>,
                body: BoxGenerator<UIView>)
    {
        super.init(frame: .zero)

        attach {
            let nav =
                ZBox().attach {
                    navBar().attach($0)
                        .width(.fill)
                        .alignment(.bottom)
                }
                .visibility(binder.visible.distinct())
                .width(.fill)
                .height($0.py_safeArea().map { SizeDescription.wrap(add: $0.top) })
                .backgroundColor(binder.backgroundColor)
                .margin(binder.navOffset.distinct().map { s in
                    UIEdgeInsets(top: s.y, left: s.x, bottom: 0, right: 0)
                })
                .alpha(binder.alpha.distinct())
                .alignment(.top)
                .viewUpdate(on: binder) { v, s in
                    v.layer.shadowOffset = s.shadowOffset
                    v.layer.shadowOpacity = s.shadowOpacity
                    v.layer.shadowRadius = s.shadowRadius
                    v.layer.shadowColor = s.shadowColor?.cgColor
                }
                .view

            let output = Outputs.merge([
                nav.py_boundsState(),
                binder.map { _ in .zero },
            ])

            body().attach($0)
                .size(.fill, .fill)
                .margin(output.map { [weak self, weak nav] _ -> UIEdgeInsets in
                    guard let self = self, let nav = nav else { return .zero }
                    if self.state.value.bodyAvoidNavBar { return .zero }
                    return .init(top: -nav.bounds.height, left: 0, bottom: 0, right: 0)
                })
                .alignment(.bottom)

            nav.attach($0)
        }
        .reverse(true)
        .animator(binder.animator)
        .justifyContent(.center)
        .size(.fill, .fill)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError()
    }
}
