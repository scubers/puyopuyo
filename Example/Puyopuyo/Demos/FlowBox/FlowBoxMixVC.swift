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

class FlowBoxMixVC: BaseVC {
    override func configView() {
        
        let reverse = false.asOutput().state()
        let hFormat = Format.leading.asOutput().state()
        let vFormat = State<Format>(.leading)
        let arrange = State<Int>(3)
        let direction = State<Direction>(.y)
        let justifyContent = State<Aligment>(.center)
        let adding = State<UIView?>(nil)
        let hSpace = State<CGFloat>(10)
        let vSpace = State<CGFloat>(10)
        
        let width = State<SizeDescription>(.fill)
        let height = State<SizeDescription>(.fill)
        
        var total = 10
        
        let spaceRange: [CGFloat] = [10, 20, 30, 40]
        
        let formatI = Iterator<Format>([.leading, .trailing, .center, .avg, .sides])
        let directionI = Iterator<Direction>([.x, .y])
        
        vRoot.attach() {
            
            HBox().attach($0) {
                UIButton().attach($0)
                    .title("change".asOutput().some(), state: .normal)
                    .addWeakAction(to: self, for: .touchUpInside, { (self, _) in
                        self.vRoot.animate(0.2, block: {
                            reverse.value = !reverse.value
                            vFormat.value = formatI.next()
                            hFormat.value = formatI.next()
                            arrange.value = Util.random(array: Array(0...total))
                            direction.value = directionI.next()
                            
                            justifyContent.value = Util.random(array: direction.value == .x ? Aligment.horzAligments() : Aligment.vertAligments())
                            
                            hSpace.value = Util.random(array: spaceRange)
                            vSpace.value = Util.random(array: spaceRange)
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
                                    .backgroundColor(Util.randomColor().asOutput().some())
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
            
            
            
            VFlow(count: 2).attach($0) {
                let heightValue: CGFloat = 20
                
                let action: () -> Void = { [weak self] in
                    self?.vRoot.animate(0.2, block: {})
                }
                
                OptionView(prefix: "width", receiver: width, options: [.fill, .wrap], action).attach($0).size(.fill, heightValue)
                OptionView(prefix: "height", receiver: height, options: [.fill, .wrap], action).attach($0).size(.fill, heightValue)
                
                OptionView(prefix: "arrange", receiver: arrange, options: Array(0...total), action).attach($0).size(.fill, heightValue)
                OptionView(prefix: "direction", receiver: direction, options: Direction.allCases, action).attach($0).size(.fill, heightValue)
                
                OptionView(prefix: "hFormat", receiver: hFormat, options: Format.allCases, action).attach($0).size(.fill, heightValue)
                OptionView(prefix: "vFormat", receiver: vFormat, options: Format.allCases, action).attach($0).size(.fill, heightValue)
                
                OptionView(prefix: "hSpace", receiver: hSpace, options: spaceRange, action).attach($0).size(.fill, heightValue)
                OptionView(prefix: "vSpace", receiver: vSpace, options: spaceRange, action).attach($0).size(.fill, heightValue)
                
                OptionView(prefix: "reverse", receiver: reverse, options: [true, false], action).attach($0).size(.fill, heightValue)
                OptionView(prefix: "content", receiver: justifyContent, options: Aligment.vertAligments() + Aligment.horzAligments(), action).attach($0).size(.fill, heightValue)
                }
                .padding(left: 10, right: 10)
                .size(.fill, .wrap)
            
            UIScrollView().attach($0) {
                VFlow(count: 3).attach($0) {
                    
                    for idx in 0..<total {
                        Label("\(idx + 1)").attach($0)
                            .width(40 + CGFloat(idx) * 3)
                            .height(on: Simulate.ego.width)
                            .styles([
                                TapRippleStyle()
                            ])
                    }
                    
                    let flow = $0
                    _ = adding.outputing({ (v) in
                        guard let v = v else { return }
                        v.attach(flow)
                            .width(40 + CGFloat(total) * 3)
                            .height(on: Simulate.ego.width)
                    })
                    
                    }
                    .width(width)
                    .height(height)
                    .padding(all: 10)
                    .margin(all: 10)
                    .hSpace(hSpace)
                    .vSpace(vSpace)
                    .justifyContent(justifyContent)
                    .direction(direction)
                    .arrangeCount(arrange)
                    .reverse(reverse)
                    .hFormat(hFormat)
                    .vFormat(vFormat)
                    .autoJudgeScroll(true)
                }
                .size(.fill, .fill)
                .margin(all: 10)
            
            }
            .justifyContent(.center)
            .space(10)
    }
}
