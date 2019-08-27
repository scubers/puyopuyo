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
    
    let formation = _S<Formation>(.leading)
    let aligment = _S<Aligment>(.center)
    let text = _S<String?>(nil)
    let reversed = _S<Bool>(false)
    
    let frame = _S<CGRect>(.zero)
    let center = _S<CGPoint>(.zero)
    
    override func configView() {
        _ = formation.receiveValue { [weak self] (f) in
            self?.refreshTitle()
        }
        _ = aligment.receiveValue { [weak self] (f) in
            self?.refreshTitle()
        }
        _ = reversed.receiveValue { [weak self] (f) in
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
                .onFrameChanged(SimpleOutput {
                    print($0)
                })
            
            }
            .size(.fill, .fill)
            .formation(self.formation)
            .space(10)
            .padding(all: 10)
            .justifyContent(self.aligment)
            .reverse(self.reversed)
    }
    
    @objc private func change() {
        vRoot.animate(0.2) {
            self.formation.value = Util.random(array: [Formation.leading, .center, .sides, .round, .trailing])
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
