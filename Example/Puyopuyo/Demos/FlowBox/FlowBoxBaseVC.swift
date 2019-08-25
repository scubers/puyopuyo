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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let reverse = _S<Bool>(false)
        let formation = _S<Formation>(.trailing)
        let subFormation = _S<Formation>(.leading)
        let text = _S<String?>(nil)
        let arrange = _S<Int>(3)
        let direction = _S<Direction>(.y)
        
        
        vRoot.attach() {
            
            UIButton().attach($0)
                .title(_S("change"), state: .normal)
                .addWeakAction(to: self, for: .touchUpInside, { (self, _) in
                    self.vRoot.animate(0.2, block: {
                        reverse.value = !reverse.value
                        subFormation.value = Util.random(array: [.leading, .center, .round, .trailing, .sides])
                        formation.value = Util.random(array: [.leading, .center, .round, .trailing, .sides])
                        arrange.value = Util.random(array: [1, 2, 3, 4, 5, 6, 7, 8])
                        direction.value = Util.random(array: [.x, .y])
                        text.value = """
                        arrange: \(arrange.value)
                        direction: \(direction.value)
                        reverse: \(reverse.value)
                        formation: \(formation.value)
                        subFormation: \(subFormation.value)
                        """
                    })
                })
                .size(100, 20)
            
            Label().attach($0)
                .text(text)
                .numberOfLines(_S(0))
                .size(.fill, .wrap)
            
            VFlow(count: 3).attach($0) {
                for idx in 0..<13 {
                    let x = Label("\(idx + 1)").attach($0)
                        .width(30)
                        .heightOnSelf({ .fix($0.width) })
                    
                    if idx == 2 {
                    }
                }
                
                }
                .size(.fill, .fill)
                .padding(all: 10)
                .margin(all: 10)
                .space(10)
                .direction(direction)
                .arrangeCount(arrange)
                .reverse(reverse)
                .formation(formation)
                .subFormation(subFormation)
            }
            .justifyContent(.center)
            .space(10)
        
        Util.randomViewColor(view: view)
    }
}
