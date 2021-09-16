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
//    var builder: (UIView) -> Void
    init(builder: (UIView) -> Void) {
//        self.builder = builder
        super.init(frame: .zero)

        attach()
            .flatBox(.y)
            .padding(all: 16)
            .animator(Animators.default)
            .space(20)
            .attach {
//                box($0)
                _ = builder($0)
            }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
}
