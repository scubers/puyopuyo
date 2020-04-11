//
//  HBoxVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/8/24.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import Puyopuyo

class HBoxVC: BaseVC {
    let one = State<Alignment>(.top)
    let two = State<Alignment>(.center)
    let three = State<Alignment>(.bottom)

    override func viewDidLoad() {
        super.viewDidLoad()

        let text1: SimpleOutput<String?> = one.asOutput().map({ $0.description })
        let text2: SimpleOutput<String?> = two.asOutput().map({ $0.description })
        let text3: SimpleOutput<String?> = three.asOutput().map({ $0.description })

        HBox().attach(vRoot) {
            Label("1").attach($0)
                .alignment(self.one)
                .height(50)
                .text(text1)
            Label("2").attach($0)
                .alignment(self.two)
                .text(text2)
                .height(50)
            Label("3").attach($0)
                .alignment(self.three)
                .text(text3)
                .height(50)
        }
        .padding(top: 50, left: 30, bottom: 10)
        .space(10)
        .size(.fill, 400)
        .borders([.thick(Util.pixel(1)), .color(.purple), .dash(5, 5)])
        .margin(all: 30)
        .animator(Animators.default)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "change", style: .plain, target: self, action: #selector(change))
        Util.randomViewColor(view: view)
    }

    @objc private func change() {
//        vRoot.animate(0.2) {
        one.value = Util.random(array: [.top, .vertCenter, .bottom])
        two.value = Util.random(array: [.top, .vertCenter, .bottom])
        three.value = Util.random(array: [.top, .vertCenter, .bottom])
//        }
    }
}
