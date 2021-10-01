//
//  DemoScroll.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/12/8.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Puyopuyo
import UIKit

class DemoScroll: UIScrollView {
    init(builder: (UIView) -> Void) {
        super.init(frame: .zero)

        attach {
            VBox().attach($0)
                .padding(all: 16)
                .animator(Animators.default)
                .space(20)
                .size(.fill, .wrap)
                .autoJudgeScroll(true)
                .attach {
                    builder($0)
                }
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
}
