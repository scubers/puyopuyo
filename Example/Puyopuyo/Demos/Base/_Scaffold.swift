//
//  Scaffold.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/12/8.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Puyopuyo
import UIKit

class NavBar: ZBox, Eventable {
    enum Event {
        case tapLeading
        case tapTrailing
        case tapTitle
    }

    var emmiter = SimpleIO<Event>()

    init(title: @escaping ViewBuilder,
         leading: ViewBuilder? = nil,
         tailing: ViewBuilder? = nil,
         navHeight: State<CGFloat> = State(44))
    {
        super.init(frame: .zero)
        attach {
            VBox().attach($0) {
                leading?($0).attach($0)
            }
            .alignment(.left)
            .onTap(to: self) { s, _ in
                s.emmiter.input(value: .tapLeading)
            }

            VBox().attach($0) {
                title($0).attach($0)
                    .size(.wrap, .wrap)
            }
            .alignment(.center)
            .onTap(to: self) { s, _ in
                s.emmiter.input(value: .tapTitle)
            }

            VBox().attach($0) {
                tailing?($0).attach($0)
            }
            .alignment(.right)
            .onTap(to: self) { s, _ in
                s.emmiter.input(value: .tapTrailing)
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
                Label(title).attach($0)
                    .fontSize(20, weight: .bold)
                    .view
            }, leading: {
                UIButton().attach($0)
                    .image(UIImage(systemName: "arrow.backward.circle.fill"))
                    .margin(all: 10, left: 0)
                    .view
            }
        )
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }
}
