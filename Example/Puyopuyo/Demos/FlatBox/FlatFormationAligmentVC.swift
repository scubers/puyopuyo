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
    
    let formation = State<Formation>(.leading)
    let aligment = State<Aligment>(.center)
    let text = State<String?>(nil)
    let reversed = State<Bool>(false)

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            
            
        }
        .size(.fill, .fill)
        .formation(self.formation)
        .space(10)
        .padding(all: 30)
        .justifyContent(self.aligment)
        .reverse(self.reversed)
        
        randomViewColor(view: view)
    }
    
    @objc private func change() {
        formation.value = random(array: [Formation.leading, .center, .sides, .trailing])
        aligment.value = random(array: [Aligment.left, .right, .center])
        reversed.value = random(array: [false, true])
        UIView.animate(withDuration: 0.25, animations: {
            self.vRoot.layoutIfNeeded()
        })
    }
    
    private func refreshTitle() {
        text.value = """
        formation: \(formation.value!)
        aligment: \(aligment.value!)
        reversed: (\(reversed.value!))
        """
    }
}
