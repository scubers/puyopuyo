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
    
    let frame = State<CGRect>(.zero)
    let center = State<CGPoint>(.zero)

    
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
                .attach() {
                    $0.py_addObserver(for: #keyPath(UIView.frame), id: "slkdjflkdsjf", block: { (value: CGRect?) in
                        print(value ?? .zero)
                    })
                }
            
            Label("4").attach($0)
                .activated(State(false))
                .frame(self.frame)
                .attach() {
                    $0.py_addObserver(for: #keyPath(UIView.frame), id: "slkdjflkdsjf", block: { (value: CGRect?) in
                        print(value ?? .zero)
                    })
                }
            
            Label("5").attach($0)
                .activated(State(false))
                .frame(State(CGRect(x: 200, y: 200, width: 60, height: 60)))
                .center(self.center)
                .attach() {
                    $0.py_addObserver(for: #keyPath(UIView.layer.position), id: "slkdjflkdsjf", block: { (value: CGRect?) in
                        print(value ?? .zero)
                    })
                }
            
        }
        .size(.fill, .fill)
        .formation(self.formation)
        .space(10)
        .justifyContent(self.aligment)
        .reverse(self.reversed)
        
        randomViewColor(view: view)
    }
    
    @objc private func change() {
        formation.value = random(array: [Formation.leading, .center, .sides, .round, .trailing])
        aligment.value = random(array: [Aligment.left, .right, .center])
        reversed.value = random(array: [false, true])
        UIView.animate(withDuration: 0.25, animations: {
            self.frame.value = self.random(array: [CGRect(x: 0, y: 0, width: 100, height: 100), CGRect(x: 100, y: 100, width: 50, height: 50)])
            self.center.value = self.random(array: [CGPoint(x: 0, y: 0), CGPoint(x: 200, y: 100)])
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
