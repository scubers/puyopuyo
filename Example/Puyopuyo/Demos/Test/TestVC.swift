//
//  TestVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/8/18.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Puyopuyo
import RxSwift
import TangramKit
import UIKit

class NewView: ZBox, Eventable {
    var eventProducer = SimpleIO<String>()
    override func buildBody() {
        attach {
            UIButton(type: .contactAdd).attach($0)
                .onEvent(.touchUpInside, SimpleInput { [weak self] _ in
                    self?.eventProducer.input(value: "100")
                })
        }
    }
}

class TestVC: BaseVC {
    var subVC: UIViewController?
//    var subVC: UIViewController? = StyleVC()
//    var subVC: UIViewController? = FlowBoxMixVC()
//    var subVC: UIViewController? = VBoxVC()
//    var subVC: UIViewController? = FlatFormationAligmentVC()

    var vv: HFlow!

    func configTestView() {
        vRoot.attach {
            VBox().attach($0) {
                HBox().attach($0) {
                    Label.demo("test demo").attach($0)
                    Label.demo("11112222").attach($0)
                }
                .format(.between)
                .size(.fill, .wrap)
            }
            .size(.fill, .wrap)
            .margin(horz: 40)
        }
//        vRoot.attach {
//            HFlow().attach($0) {
//                Label.demo("lskdjfl").attach($0)
//                    .size(50, 50)
//                    .margin(all: 10)
//            }
//
//            VFlow(count: 0).attach($0) {
//                for i in 0 ..< 9 {
//                    if i < 3 {
//                        Label.demo(i.description).attach($0)
//                            .height(.ratio(2))
//                    } else if i == 4 {
//                        Label.demo(i.description).attach($0)
//                            .margin(all: 8)
//                            .size(.fill, .ratio(3))
//                    } else {
//                        Label.demo(i.description).attach($0)
//                            .size(.fill, .ratio(CGFloat(i)))
//                    }
//                }
//            }
//            .space(4)
//            .padding(all: 8)
//            .size(.fill, .fill)
        ////            .size(200, 200)
//        }
//        .format(.between)
//        .padding(all: 10)
//        .space(10)
//        .animator(Animators.default)
    }

    private func test1() {
        vRoot.attach()
            .space(10)
            .attach {
                HBox().attach($0)
                    .size(.fill, 100)
                    .margin(all: 10)
                    .padding(all: 10)
                    .attach {
                        Label("正").attach($0)
                            .height(.fill)
                            .width(simulate: Simulate.ego.height.multiply(0.5))

                        Label("fill").attach($0)
                            .size(.fill, .fill)

                        let v = $0
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                            self.vRoot.animate(0.2, block: {
                            v.attach().height(200)
//                            })
                        }
                    }

                let v = ZBox().attach($0) {
                    let total = 10
                    for idx in 0 ..< total {
                        UIView().attach($0)
                            .width(on: $0) { .fix($0.width * (1 - CGFloat(idx) / CGFloat(total))) }
                            .height(on: $0) { .fix($0.height * (1 - CGFloat(idx) / CGFloat(total))) }
                    }
                }
                .width(.fill)
                .height(simulate: Simulate.ego.width.multiply(0.5))
//                    .heightOnSelf({ .fix($0.width * 0.5) })

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                    v.view.animate(0.25, block: {
//                        v.heightOnSelf({ .fix($0.width) })
                    v.height(simulate: Simulate.ego.width)
//                    })
                }
            }
    }

    override func shouldRandomColor() -> Bool {
        return true
    }

    private func tk_flowTest() {
        //        TGFlowLayout(.vert, arrangedCount: 3).attach() { x in
        TGFloatLayout().attach { x in

            let labels = Array(repeating: 1, count: 10).map { idx in
                Label("\(idx)")
            }

            for (idx, label) in labels.enumerated() {
                label.attach(x)
                    .text("\(idx)".asOutput().some())
                    .tg_size(50 + idx * 3, 50 + idx * 3 + 1)

                //                if idx % 3 == 2 && idx != 2 {
                if idx == 2 {
                    label.tg_reverseFloat = true
                    //                    label.attach().tg_size(.fill, 50)
                }
            }
        }
        .size(.fill, .fill)
        .tg_gravity(TGGravity.horz.right)
        .tg_size(.fill, .fill)
        .activated(State(false))
        .attach(vRoot)
    }

    override func configView() {
        vRoot.attach {
            if let v = self.subView() {
                self.addChild(self.subVC!)
                v.attach($0)
                    .size(.fill, .fill)
            } else {
                self.configTestView()
            }
        }
    }

    func subView() -> UIView? {
        if let type = subVC {
            return type.view
        }
        return nil
    }
}
