//
//  Flat1VC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/6/30.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Puyopuyo
import RxSwift
import TangramKit

class Flat1VC: BaseVC {
    
    var visible = State<Visiblity>(.visible)
    var margin = State<UIEdgeInsets>(.zero)
    var aligment = State<Aligment>(.center)
    var direction = State<Direction>(.x)
    var subMargin = State<UIEdgeInsets>(.zero)
    var width = State<SizeDescription>(.fixed(10))
    var space = BehaviorSubject<CGFloat>(value: 5)
    
    var text = BehaviorSubject<String>(value: "")
    var switchChange = BehaviorSubject<Bool>(value: false)
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        text.subscribe(onNext: { s in
            print(s)
        }).disposed(by: bag)
        
        switchChange.subscribe(onNext: {
            print($0)
        }).disposed(by: bag)
        
        getLabel("text").attach(vRoot)
            .text(text.map({ x -> String? in x}))
            .width(.wrap(add: 10))
            .textAligment(State(.center))
            .aligment(.center)
            .textColor(State(.white).optional())
            .visible(switchChange.map({ $0 ? .visible : .gone}))
        
        UIButton(type: .contactAdd).attach(vRoot)
            .addAction(for: .touchUpInside, { (btn) in
                print(btn)
            })
        
        UISwitch().attach(vRoot)
            .isOn(switchChange)
        
//        UITextField().attach(vRoot)
//            .size(.ratio(1), 30)
//            .onText(text)
//            .visible(switchChange.map({ $0 ? .visible : .gone}))
//            .addAction(for: [.editingDidBegin, .editingDidEnd], {
//                print($0)
//            })
//        
        HBox().attach(vRoot) {

            
            for idx in 0..<30 {
                self.getView().attach($0)
                    .width(self.width)
                    .height(10 * (idx + 1))
                    .margin(self.subMargin)
                    .aligment(self.aligment)
            }
        }
        .space(space)
        .size(.ratio(1), .wrap)
        .padding(all: 10)
        .justifyContent(.bottom)
        .margin(margin)
        .direction(direction)
        .visible(visible)
        .cornerRadius(State(10))
        
        ZBox().attach(vRoot) {
            TGLinearLayout(.vert).attach($0) {
                self.getLabel("1111").tg_attach($0)
                self.getLabel("222").tg_attach($0)
                }
                .size(.fill, .fill)
                .tg_gravity(.center)
        }
        .size(.fill, .fill)
        
        randomViewColor(view: vRoot)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.margin.value = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            self.aligment.value = .bottom
            self.subMargin.value = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
            self.width.value = .fill
            self.space.onNext(0)
            self.vRoot.attach()
                .formation(.center)
            self.switchChange.onNext(true)
            
            self.text.onNext("100")

            UIView.animate(withDuration: 0.5, animations: {
                self.vRoot.layoutIfNeeded()
            })
        }
    }
}
