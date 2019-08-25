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
        
        let total = 10
        
        vRoot.attach() {
            
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
            
            VBox().attach($0) {
                let height: CGFloat = 20
                OptionView(vc: self, prefix: "arrange", receiver: arrange, options: Array(1...total)).attach($0).size(.fill, height)
                OptionView(vc: self, prefix: "direction", receiver: direction, options: Direction.allCases).attach($0).size(.fill, height)
                OptionView(vc: self, prefix: "reverse", receiver: reverse, options: [true, false]).attach($0).size(.fill, height)
                OptionView(vc: self, prefix: "formation", receiver: formation, options: Formation.allCases).attach($0).size(.fill, height)
                OptionView(vc: self, prefix: "subFormation", receiver: subFormation, options: Formation.allCases).attach($0).size(.fill, height)
                }
                .padding(left: 10, right: 10)
                .size(.fill, .wrap)
            
//            Label().attach($0)
//                .text(text)
//                .numberOfLines(_S(0))
//                .size(.fill, .wrap)
            
            VFlow(count: 3).attach($0) {
                for idx in 0..<total {
                    Label("\(idx + 1)").attach($0)
                        .width(30 + idx * 3)
//                        .width(Simulate($0).width.multiply(0.2))
                        .heightOnSelf({ .fix($0.width) })
                    
                    if idx == 2 {
//                        x.height(.fill)
                    }
                }
                
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
