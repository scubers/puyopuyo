//
//  FlowBoxBaseVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/8/25.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Puyopuyo
import RxSwift

class FlowBoxBaseVC: BaseVC {
    override func configView() {
        
        let reverse = _St<Bool>(false)
        let formation = _St<Format>(.trailing)
        let subFormation = _St<Format>(.leading)
        let text = _St<String?>(nil)
        let arrange = _St<Int>(3)
        let direction = _St<Direction>(.y)
        let justifyContent = _St<Aligment>(.center)
        let adding = _St<UIView?>(nil)
        
        var total = 10
        
        vRoot.attach() {
            
            HBox().attach($0) {
                UIButton().attach($0)
                    .title(_St("change"), state: .normal)
                    .addWeakAction(to: self, for: .touchUpInside, { (self, _) in
                        self.vRoot.animate(0.2, block: {
                            reverse.value = !reverse.value
                            subFormation.value = Util.random(array: [.leading, .trailing, .center, .avg, .sides])
                            formation.value = Util.random(array: [.leading, .trailing, .center, .avg, .sides])
                            arrange.value = Util.random(array: Array(1...total))
                            direction.value = Util.random(array: [.x, .y])
                            
                            justifyContent.value = Util.random(array: direction.value == .x ? Aligment.horzAligments() : Aligment.vertAligments())
                            text.value = """
                            arrange: \(arrange.value)
                            direction: \(direction.value)
                            reverse: \(reverse.value)
                            formation: \(formation.value)
                            subFormation: \(subFormation.value)
                            content: \(justifyContent.value)
                            """
                        })
                    })
                    .size(100, 20)
                
                UIButton().attach($0)
                    .title(State("add"), state: .normal)
                    .addWeakAction(to: self, for: .touchUpInside, { (self, _) in
                        self.vRoot.animate(0.2, block: {
                            total += 1
                            let v =
                                Label("\(total)").attach()
                                    .size(40, 40)
                                    .backgroundColor(State(Util.randomColor()).optional())
                                    .onTap(to: self, { (self, tap) in
                                        self.vRoot.animate(0.2, block: {
                                            tap.view?.removeFromSuperview()
                                            total -= 1
                                        })
                                    })
                                    .view
                            
                            adding.input(value: v)
                        })
                    })
                    .size(50, .fill)
                }
                .size(.fill, 20)
            
            
            
            VBox().attach($0) {
                let height: CGFloat = 20
                OptionView(prefix: "arrange", receiver: arrange, options: Array(1...total)).attach($0).size(.fill, height)
                OptionView(prefix: "direction", receiver: direction, options: Direction.allCases).attach($0).size(.fill, height)
                OptionView(prefix: "reverse", receiver: reverse, options: [true, false]).attach($0).size(.fill, height)
                OptionView(prefix: "formation", receiver: formation, options: Format.allCases).attach($0).size(.fill, height)
                OptionView(prefix: "subFormation", receiver: subFormation, options: Format.allCases).attach($0).size(.fill, height)
                OptionView(prefix: "content", receiver: justifyContent, options: Aligment.vertAligments() + Aligment.horzAligments()).attach($0).size(.fill, height)
                }
                .padding(left: 10, right: 10)
                .size(.fill, .wrap)
            
            UIScrollView().attach($0) {
                VFlow(count: 3).attach($0) {
                    
                    for idx in 0..<total {
                        let x =
                            Label("\(idx + 1)").attach($0)
                                .width(40)
                                .height(Simulate.ego.width)
                                //                        .height(on: $0, { .fix($0.width * 0.2)})
//                                .height(Simulate($0).width.multiply(0.2))
                        //                        .height(Simulate().simulateSelf().width)
                        //                        .height(40)
                        
                        //                        .width(Simulate($0).width.multiply(0.2))
                        //                        .heightOnSelf({ .fix($0.width) })
                        
                    }
                    
                    let flow = $0
                    _ = adding.receiveOutput({ (v) in
                        guard let v = v else { return }
                        v.attach(flow)
                    })
                    
                    }
                    .size(.wrap, .wrap)
                    .size(.fill, .fill)
                    .padding(all: 10)
                    .margin(all: 10)
                    .space(10)
                    .justifyContent(justifyContent)
                    .direction(direction)
                    .arrangeCount(arrange)
                    .reverse(reverse)
                    .format(formation)
                    .autoJudgeScroll(false)
                    .subFormat(subFormation)
                }
                .size(.fill, .fill)
                .margin(all: 10)
            
            }
            .justifyContent(.center)
            .space(10)
    }
}
