//
//  StatefulVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/8/11.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift
import Puyopuyo

class StatefulVC: BaseVC, UITextFieldDelegate {
    
    var text = State("text").optional()
    var textColor = State<UIColor>(.black)
    lazy var backgroundColor = State<UIColor>(self.randomColor())
    var width = State<SizeDescription>(.fixed(100))
    var height = State<SizeDescription>(.fixed(100))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIScrollView().attach(vRoot) {
            
            VBox().attach($0) {
                
                UISwitch().attach($0)
                    .addWeakBind(to: self, for: .valueChanged, { StatefulVC.valueChanged($0) })
                
                UIButton(type: .contactAdd).attach($0)
                    .addWeakAction(to: self, for: [.touchDragInside], { (self, _) in self.valueChanged(UISwitch())})
                
                UITextField().attach($0)
                    .placeholder(State("this is a textfiled"))
                    .width(.wrap(min: 100, max: 200))
                    .height(50)
                    .onText(self.text)
                
                Label("").attach($0)
                    .numberOfLines(State(0))
                    .text(self.text)
                    .width(.wrap(min: 50, max: 100))
                    .height(.wrap(min: 40, max: 150))
                
                Label("").attach($0)
                    .text(self.text)
                    .textColor(self.textColor.optional())
                    .size(self.width, self.height)
                
                Label("").attach($0)
                    .text(self.text)
                    .backgroundColor(self.backgroundColor.optional())
                    .size(self.width, self.height)
            }
            .space(10)
            .size(.fill, .wrap)
            .padding(all: 10)
            .justifyContent(.center)
        }
        .size(.fill, .fill)
        
        randomViewColor(view: view)
    }
    
    private func valueChanged(_ view: UISwitch) -> Void {
        change(value: view.isOn)
    }
    
    private func change(value: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.text.value = "A random string: \(arc4random_uniform(10))"
            self.width.value = self.randomSize()
            self.height.value = self.randomSize()
            self.textColor.value = self.randomColor()
            self.backgroundColor.value = self.randomColor()
            self.vRoot.layoutIfNeeded()
        }
    }
    
    private func randomSize() -> SizeDescription {
        return random(array: [.fill, .wrap, .fixed(100)])
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(string)
        return true
    }
}
