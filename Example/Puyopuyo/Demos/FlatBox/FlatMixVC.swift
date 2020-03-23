//
//  FlatFormationVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/8/18.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Puyopuyo
import UIKit

class FlatMixVC: BaseVC {
    let formation = State<Format>(.between)
    let aligment = State<Alignment>(.center)
    let text = State<String?>(nil)
    let reversed = State<Bool>(false)

    let frame = State<CGRect>(.zero)
    let center = State<CGPoint>(.zero)

    override func configView() {
        _ = formation.outputing { [weak self] _ in
            self?.refreshTitle()
        }
        _ = aligment.outputing { [weak self] _ in
            self?.refreshTitle()
        }
        _ = reversed.outputing { [weak self] _ in
            self?.refreshTitle()
        }

//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "change", style: .plain, target: self, action: #selector(change))
        let btn = Label("change")
            .attach()
            .frame(w: 60, h: 40)
            .styleSheet(.mainButton)
            .onTap(to: self, { s, _ in
                s.change()
            })
            .view
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)

        vRoot.attach {
            Label().attach($0)
                .numberOfLines(State(0))
                .text(self.text)
                .styleSheet(.mainButton)

            Label("1").attach($0)
                .textAlignment(State(.center))
                .size(100, 50)
                .styleSheet(.mainButton)

            Label("2").attach($0)
                .textAlignment(State(.center))
                .size(100, 100)
                .styleSheet(.mainButton)

            Label("3").attach($0)
                .textAlignment(State(.center))
                .size(50, 50)
                .styleSheet(.mainButton)

            UIButton().attach($0)
                .activated(false)
                .text("change")
                .bind(to: self, event: .touchUpInside, action: { (this, _) in
                    this.change()
                })
                .frameY(Simulate($0).height.add(-20))
                .frame(w: 100, h: 20)
        }
        .size(.fill, .fill)
        .format(formation)
        .space(10)
        .padding(all: 10)
        .justifyContent(aligment)
        .reverse(reversed)
    }

    @objc private func change() {
//        vRoot.animate(0.2) {
        formation.value = Util.random(array: [Format.leading, .center, .between, .round, .trailing])
        aligment.value = Util.random(array: [Alignment.left, .right, .center])
        reversed.value = Util.random(array: [false, true])
//        }
    }

    private func refreshTitle() {
        text.value = """
        formation: \(formation.value)
        aligment: \(aligment.value)
        reversed: (\(reversed.value))
        """
    }
}
