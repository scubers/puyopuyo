//
//  DemoScroll.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/12/8.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Puyopuyo
import UIKit

class DemoScroll: ZBox {
    init(builder: (UIView) -> Void) {
        super.init(frame: .zero)

        attach {
            UIScrollView().attach($0) {
                let padding = $0.py_safeArea().binder.map { area -> UIEdgeInsets in
                    print(area)
                    return UIEdgeInsets(top: 16, left: area.left + 16, bottom: area.bottom, right: area.right + 16)
                }
                VBox().attach($0)
                    .padding(padding)
                    .animator(Animators.default)
                    .space(20)
                    .size(.fill, .wrap)
                    .autoJudgeScroll(true)
                    .attach {
                        builder($0)
                    }
                    .size(.fill, .wrap)
            }
            .size(.fill, .fill)
        }
        .size(.fill, .fill)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
}
