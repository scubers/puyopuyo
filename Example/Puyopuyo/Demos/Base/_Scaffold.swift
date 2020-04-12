//
//  Scaffold.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/12/8.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Puyopuyo
import UIKit

class _Scaffold: UIView {
    init(navBar: ViewBuilder? = nil, body: @escaping ViewBuilder) {
        super.init(frame: .zero)

        VBox().attach(self) {
            ZBox().attach($0) {
                navBar?($0).attach($0)
                    .width(.fill)
                    .alignment(.bottom)
            }
            .bottomBorder([.color(UIColor.black.withAlphaComponent(0.2)), .thick(Util.pixel(1))])
            .width(.fill)
            .height($0.py_safeArea().distinct().map { SizeDescription.wrap(add: $0.top) })

            body($0).attach($0)
                .size(.fill, .fill)
        }
        .size(.fill, .fill)
    }

    required init?(coder _: NSCoder) {
        fatalError()
    }
}

class NavBar: ZBox, Eventable {
    enum Event {
        case tapLeading
        case tapTrailing
        case tapTitle
    }

    var eventProducer = SimpleIO<Event>()

    init(title: @escaping ViewBuilder,
         leading: ViewBuilder? = nil,
         tailing: ViewBuilder? = nil,
         navHeight: State<CGFloat> = State(44)) {
        super.init(frame: .zero)
        attach {
            VBox().attach($0) {
                leading?($0).attach($0)
            }
            .alignment(.left)
            .onTap(to: self) { s, _ in
                s.eventProducer.input(value: .tapLeading)
            }

            VBox().attach($0) {
                title($0).attach($0)
                    .size(.wrap, .wrap)
            }
            .alignment(.center)
            .onTap(to: self) { s, _ in
                s.eventProducer.input(value: .tapTitle)
            }

            VBox().attach($0) {
                tailing?($0).attach($0)
            }
            .alignment(.right)
            .onTap(to: self) { s, _ in
                s.eventProducer.input(value: .tapTrailing)
            }
        }
        .justifyContent(.vertCenter)
        .padding(left: 16, right: 16)
        .width(.fill)
        .height(navHeight)
    }

    convenience init(title: String) {
        self.init(
            title: {
                Label(title).attach($0).view
            }, leading: {
                UIButton().attach($0)
                    .text("<-  ")
                    .textColor(UIColor.black)
                    .userInteractionEnabled(false)
                    .view
            }
        )
    }

    required init?(coder _: NSCoder) {
        fatalError()
    }
}
