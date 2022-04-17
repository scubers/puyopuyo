//
//  ScrollVC.swift
//  Puyopuyo_Example
//
//  Created by J on 2021/9/28.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import Puyopuyo

class ScrollVC: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        VBox().attach(view) {
            UIScrollView().attach($0) {
                VBox().attach($0) {
                    UILabel().attach($0)
                        .width(.fill)
                        .numberOfLines(0)
                        .text("""
                        If BoxView is the Subview of a UIScrollView, set boxview autoJudgeScroll, size = .wrap.
                        The BoxView will control then UIScrollView's contentSize after calculate
                        """)
                    for i in 0 ..< 40 {
                        Label.demo(i.description).attach($0)
                            .size(50, 50)
                    }
                }
                .justifyContent(.center)
                .space(10)
                .size(.fill, .wrap)
                .autoJudgeScroll(true)
            }
            .size(.fill, .fill)
        }
        .size(.fill, .fill)
        .padding(all: 10)
    }
}
