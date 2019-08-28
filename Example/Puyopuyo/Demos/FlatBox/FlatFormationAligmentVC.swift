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
    
    let formation = _St<Format>(.leading)
    let aligment = _St<Aligment>(.center)
    let text = _St<String?>(nil)
    let reversed = _St<Bool>(false)
    
    let frame = _St<CGRect>(.zero)
    let center = _St<CGPoint>(.zero)
    
    override func configView() {
        _ = formation.receiveOutput { [weak self] (f) in
            self?.refreshTitle()
        }
        _ = aligment.receiveOutput { [weak self] (f) in
            self?.refreshTitle()
        }
        _ = reversed.receiveOutput { [weak self] (f) in
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
                .onFrameChanged(SimpleInput {
                    print($0)
                })
            
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
