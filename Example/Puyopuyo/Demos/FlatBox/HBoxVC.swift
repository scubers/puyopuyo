//
//  HBoxVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/8/24.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import Puyopuyo

class HBoxVC: BaseVC {
    
    let one = _St<Aligment>(.top)
    let two = _St<Aligment>(.center)
    let three = _St<Aligment>(.bottom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let text1: _St<String?> = one.map({ $0.description })
        let text2: _St<String?> = two.map({ $0.description })
        let text3: _St<String?> = three.map({ $0.description })
        
        HBox().attach(vRoot) {
            Label("1").attach($0)
                .aligment(self.one)
                .height(50)
                .text(text1)
            Label("2").attach($0)
                .aligment(self.two)
                .text(text2)
                .height(50)
            Label("3").attach($0)
                .aligment(self.three)
                .text(text3)
                .height(50)
            }
            .padding(top: 50, left: 30, bottom: 10)
            .space(10)
            .size(.fill, 400)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "change", style: .plain, target: self, action: #selector(change))
        Util.randomViewColor(view: view)
    }
    
    @objc private func change() {
        vRoot.animate(0.2) {
            self.one.value = Util.random(array: [.top, .vertCenter, .bottom])
            self.two.value = Util.random(array: [.top, .vertCenter, .bottom])
            self.three.value = Util.random(array: [.top, .vertCenter, .bottom])
        }
    }
}
