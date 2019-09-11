//
//  TestVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/8/18.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Puyopuyo
import TangramKit
import RxSwift

class Instance: NSObject {
    static var share = Instance()
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
    }
}

struct MyParts {
    
}

class TestVC: BaseVC {
    
    var subVC: UIViewController? = nil
//    var subVC: UIViewController? = FlowBoxBaseVC()
//    var subVC: UIViewController? = VBoxVC()
//    var subVC: UIViewController? = FlatFormationAligmentVC()
    
    let state = State<Visibility>(.visible)
    func configTestView() {
        
        vRoot.attach {
            
            let state = "".yo.someState()
            
            UIButton().attach($0)
                .title("确定", state: .normal)
            
            UITextView().attach($0)
                .size(.fill, .wrap(min: 30))
                .font(UIFont.systemFont(ofSize: 14))
                .onText(state)
            
            UITextField().attach($0)
                .resizeByContent()
                .textAligment(.center)
                .size(.wrap(add: 10, min: 50), 50)
                .onText(state)
                .onEvent(.editingDidBegin, SimpleInput { _ in
                    print("begin")
                })
                .onEvent(.editingDidEnd, SimpleInput { _ in
                    print("end")
                })
            
            Label().attach($0)
                .text("111")
            
            HLine().attach($0) {
                UITextField().attach($0) {
                    $0.tg_width >= 50
                    $0.tg_height.equal(50)
                }
                .onText(state)
                }
                .size(.fill, 50)

            }
            .space(10)

    }
    
    private func test1() {
        vRoot.attach()
            .space(10)
            .attach() {
                
                HBox().attach($0)
                    .size(.fill, 100)
                    .margin(all: 10)
                    .padding(all: 10)
                    .attach() {
                        
                        Label("正").attach($0)
                            .height(.fill)
                            .widthOnSelf({ .fix($0.height) })
                            .widthOnSelf({ .fix($0.height * 0.5) })
                        
                        Label("fill").attach($0)
                            .size(.fill, .fill)
                        
                        let v = $0
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            self.vRoot.animate(0.2, block: {
                                v.attach().height(200)
                            })
                        })
                }
                
                
                let v = ZBox().attach($0) {
                    
                    let total = 10
                    for idx in 0..<total {
                        UIView().attach($0)
                            .width(on: $0, { .fix($0.width * (1 - CGFloat(idx) / CGFloat(total))) })
                            .height(on: $0, { .fix($0.height * (1 - CGFloat(idx) / CGFloat(total))) })
                    }
                    
                    
                    }
                    .width(.fill)
                    .heightOnSelf({ .fix($0.width * 0.5) })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    v.view.animate(0.25, block: {
                        v.heightOnSelf({ .fix($0.width) })
                    })
                })
                
                
                
        }
    }
    
    private func tk_flowTest() {
        //        TGFlowLayout(.vert, arrangedCount: 3).attach() { x in
        TGFloatLayout().attach() { x in
            
            let labels = Array(repeating: 1, count: 10).map({ (idx) in
                return Label("\(idx)")
            })
            
            for (idx, label) in labels.enumerated() {
                label.attach(x)
                    .text("\(idx)".yo.some())
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
        vRoot.attach() {
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
