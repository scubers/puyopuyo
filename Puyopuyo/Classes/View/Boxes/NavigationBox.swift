//
//  NavigationBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/15.
//

import UIKit

public class NavigationBox: VBox, Stateful {
    public struct ViewState {
        public init() {}
        public var visible: Visibility = .visible
        public var navOffset = CGPoint.zero
        public var bodyAvoidNavBar = true
        public var backgroundColor: UIColor = .white
        public var animator: Animator = Animators.default
        public var alpha: CGFloat = 1
    }

    public var viewState = State(ViewState())

    public init(navBar: @escaping BoxGenerator<UIView>,
                body: @escaping BoxGenerator<UIView>) {
        super.init(frame: .zero)

        attach {
            let nav =
                ZBox().attach {
                    navBar().attach($0)
                        .width(.fill)
                        .alignment(.bottom)
                }
                .visibility(self.viewState.asOutput().map({ $0.visible }))
                .width(.fill)
                .height($0.py_safeArea().map({ SizeDescription.wrap(add: $0.top) }))
                .backgroundColor(self.viewState.asOutput().map({ $0.backgroundColor }))
                .margin(self.viewState.asOutput().map({ (s) -> UIEdgeInsets in
                    .init(top: s.navOffset.y, left: s.navOffset.x, bottom: 0, right: 0)
                }))
                .alpha(self.viewState.asOutput().map({ $0.alpha }))
                .alignment(.top)
                .view

            let output = SimpleOutput.merge([
                nav.py_boundsState(),
                self.viewState.asOutput().map({ _ in .zero }),
            ])

            body().attach($0)
                .size(.fill, .fill)
                .margin(output.map({ [weak self, weak nav] (_) -> UIEdgeInsets in
                    guard let self = self, let nav = nav else { return .zero }
                    if self.viewState.value.bodyAvoidNavBar { return .zero }
                    return .init(top: -nav.bounds.height, left: 0, bottom: 0, right: 0)
                }))
                .alignment(.bottom)

            nav.attach($0)
        }
        .reverse(true)
        .animator(viewState.asOutput().map({ $0.animator }))
        .justifyContent(.center)
        .size(.fill, .fill)
    }

    public required init?(coder _: NSCoder) {
        fatalError()
    }
}
