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
        let hFormat = _St<Format>(.trailing)
        let vFormat = _St<Format>(.leading)
        let arrange = _St<Int>(3)
        let direction = _St<Direction>(.y)
        let justifyContent = _St<Aligment>(.center)
        let adding = _St<UIView?>(nil)
        let hSpace = _St<CGFloat>(10)
        let vSpace = _St<CGFloat>(10)
        
        var total = 10
        
        let spaceRange: [CGFloat] = [10, 20, 30, 40]
        
        let formatI = Iterator<Format>([.leading, .trailing, .center, .avg, .sides])
        let directionI = Iterator<Direction>([.x, .y])
        
        vRoot.attach() {
            
            HBox().attach($0) {
                UIButton().attach($0)
                    .title(_St("change"), state: .normal)
                    .addWeakAction(to: self, for: .touchUpInside, { (self, _) in
                        self.vRoot.animate(0.2, block: {
                            reverse.value = !reverse.value
                            vFormat.value = formatI.next()
                            hFormat.value = formatI.next()
                            arrange.value = Util.random(array: Array(1...total))
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
                OptionView(prefix: "hFormat", receiver: hFormat, options: Format.allCases).attach($0).size(.fill, height)
                OptionView(prefix: "vFormat", receiver: vFormat, options: Format.allCases).attach($0).size(.fill, height)
                OptionView(prefix: "hSpace", receiver: hSpace, options: spaceRange).attach($0).size(.fill, height)
                OptionView(prefix: "vSpace", receiver: vSpace, options: spaceRange).attach($0).size(.fill, height)
                OptionView(prefix: "content", receiver: justifyContent, options: Aligment.vertAligments() + Aligment.horzAligments()).attach($0).size(.fill, height)
                }
                .padding(left: 10, right: 10)
                .size(.fill, .wrap)
            
            UIScrollView().attach($0) {
                VFlow(count: 3).attach($0) {
                    
                    let fix = Label("fix").attach($0).activated(false)
                    for idx in 0..<total {
                        let x =
                            Label("\(idx + 1)").attach($0)
                                .width(40)
//                                .height(40)
                                .height(on: Simulate.ego.width)
                                //                        .height(on: $0, { .fix($0.width * 0.2)})
//                                .height(Simulate($0).width.multiply(0.2))
                        //                        .height(Simulate().simulateSelf().width)
                        //                        .height(40)
                        
                        //                        .width(Simulate($0).width.multiply(0.2))
                        //                        .heightOnSelf({ .fix($0.width) })
                        
                        if idx == 0 {
                            fix
                                .top(Simulate(x.view).top.add(-10))
                                .left(Simulate(x.view).left.add(-10))
                        }
                        if idx == 9 {
                            fix
                                .bottom(Simulate(x.view).bottom.add(10))
                                .right(Simulate(x.view).right.add(10))
                        }
                        
                    }
                    
                    

                    
                    let flow = $0
                    _ = adding.outputing({ (v) in
                        guard let v = v else { return }
                        v.attach(flow)
                    })
                    
                    }
                    .size(.wrap, .wrap)
                    .size(.fill, .fill)
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
                    .autoJudgeScroll(false)
                }
                .size(.fill, .fill)
                .margin(all: 10)
            
            }
            .justifyContent(.center)
            .space(10)
    }
}
