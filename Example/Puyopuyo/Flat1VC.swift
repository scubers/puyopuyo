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

class Flat1VC: BaseVC {
    
    var visible = State<Visiblity>(value: .visible)
    var margin = State<UIEdgeInsets>(value: .zero)
    var aligment = State<Aligment>(value: .center)
    var direction = State<Direction>(value: .x)
    var subMargin = State<UIEdgeInsets>(value: .zero)
    var width = State<SizeDescription>(value: .fixed(10))
    var space = BehaviorSubject<CGFloat>(value: 5)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getLabel("text").attach(vRoot)
            .text(State(value: "slkdjf"))
            .width(.wrap(add: 10))
            .textAligment(State(value: NSTextAlignment.center))
            .aligment(.center)
            .textColor(State(value: UIColor.black))
        
        HBox.attach(vRoot) {
            for idx in 0..<15 {
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
        .cornerRadius(State(value: 10))
        
        randomViewColor(view: vRoot)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.margin.value = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            self.aligment.value = .bottom
            self.subMargin.value = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
            self.width.value = .fill
            self.space.onNext(0)
            self.vRoot.attach()
                .formation(.center)
            

            UIView.animate(withDuration: 0.5, animations: {
                self.vRoot.layoutIfNeeded()
            })
        }
    }
}
