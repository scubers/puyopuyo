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
        
        let reverse = _S<Bool>(false)
        let formation = _S<Formation>(.trailing)
        let subFormation = _S<Formation>(.leading)
        let text = _S<String?>(nil)
        let arrange = _S<Int>(3)
        let direction = _S<Direction>(.y)
        let justifyContent = _S<Aligment>(.center)
        let adding = _S<UIView?>(nil)
        
        var total = 10
        
        vRoot.attach() {
            
            HBox().attach($0) {
                UIButton().attach($0)
                    .title(_S("change"), state: .normal)
                    .addWeakAction(to: self, for: .touchUpInside, { (self, _) in
                        self.vRoot.animate(0.2, block: {
                            reverse.value = !reverse.value
                            subFormation.value = Util.random(array: [.leading, .trailing, .center, .round, .sides])
                            formation.value = Util.random(array: [.leading, .trailing, .center, .round, .sides])
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
                            
                            adding.postValue(v)
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
                OptionView(prefix: "formation", receiver: formation, options: Formation.allCases).attach($0).size(.fill, height)
                OptionView(prefix: "subFormation", receiver: subFormation, options: Formation.allCases).attach($0).size(.fill, height)
                OptionView(prefix: "content", receiver: justifyContent, options: Aligment.vertAligments() + Aligment.horzAligments()).attach($0).size(.fill, height)
                }
                .padding(left: 10, right: 10)
                .size(.fill, .wrap)
            
            VFlow(count: 3).attach($0) {
                
                var top: ValueModifiable!
                var left: ValueModifiable!
                var bottom: ValueModifiable!
                var right: ValueModifiable!
                
                for idx in 0..<total {
                    let x =
                    Label("\(idx + 1)").attach($0)
                        .width(40)
                        .height(40)
//                        .width(Simulate($0).width.multiply(0.2))
//                        .heightOnSelf({ .fix($0.width) })
                    
                    if idx == 0 {
                        top = Simulate(x.view).top
                        left = Simulate(x.view).left
                    }
                    if idx == 1 {
                        bottom = Simulate(x.view).bottom
                        right = Simulate(x.view).right
                    }
                    
                }
                Label("-1").attach($0)
                    .activated(_S(false))
                    .top(top)
                    .left(left)
                    .bottom(bottom)
                    .right(right)
                
                
                
                let flow = $0
                _ = adding.receiveValue({ (v) in
                    guard let v = v else { return }
                    v.attach(flow)
                })
                
                }
                .size(.fill, .fill)
//                .size(.wrap, .wrap)
                .padding(all: 10)
                .margin(all: 10)
                .space(10)
                .justifyContent(justifyContent)
                .direction(direction)
                .arrangeCount(arrange)
                .reverse(reverse)
                .formation(formation)
                .subFormation(subFormation)
            }
            .justifyContent(.center)
            .space(10)
    }
}