//
//  FlatFormationVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/8/18.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Puyopuyo

class FlatFormationAligmentVC: BaseVC {
    
    let formation = State<Format>(.sides)
    let aligment = State<Aligment>(.center)
    let text = State<String?>(nil)
    let reversed = State<Bool>(false)
    
    let frame = State<CGRect>(.zero)
    let center = State<CGPoint>(.zero)
    
    override func configView() {
        _ = formation.outputing { [weak self] (f) in
            self?.refreshTitle()
        }
        _ = aligment.outputing { [weak self] (f) in
            self?.refreshTitle()
        }
        _ = reversed.outputing { [weak self] (f) in
            self?.refreshTitle()
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "change", style: .plain, target: self, action: #selector(change))
        
        vRoot.attach() {
            
            Label().attach($0)
                .numberOfLines(State(0))
                .text(self.text)
            
            Label("1").attach($0)
                .textAligment(State(.center))
                .size(100, 50)
            
            Label("2").attach($0)
                .textAligment(State(.center))
                .size(100, 100)
            
            Label("3").attach($0)
                .textAligment(State(.center))
                .size(50, 50)
            
            UIButton().attach($0)
                .activated(false)
                .title(State("change"), state: .normal)
                .addWeakAction(to: self, for: .touchUpInside, { (self, _) in
                    self.change()
                })
                .frameY(Simulate($0).height.add(-20))
                .frame(w: 100, h: 20)
            }
            .size(.fill, .fill)
            .format(self.formation)
            .space(10)
            .padding(all: 10)
            .justifyContent(self.aligment)
            .reverse(self.reversed)
    }
    
    @objc private func change() {
        vRoot.animate(0.2) {
            self.formation.value = Util.random(array: [Format.leading, .center, .sides, .avg, .trailing])
            self.aligment.value = Util.random(array: [Aligment.left, .right, .center])
            self.reversed.value = Util.random(array: [false, true])
        }
    }
    
    private func refreshTitle() {
        text.value = """
        formation: \(formation.value)
        aligment: \(aligment.value)
        reversed: (\(reversed.value))
        """
    }
}
