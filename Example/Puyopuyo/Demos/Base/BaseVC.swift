//
//  BaseVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/6/30.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Puyopuyo

class BaseVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isTranslucent = false
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back", style: .plain, target: self, action: #selector(BaseVC.back))
        vRoot.attach(view).size(.ratio(1), .ratio(1))
    }
    
    var vRoot: VBox = VBox()
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    
    func configVRoot(_ block: (VBox) -> Void) {
        block(vRoot)
    }
    
    func getView(_ color: UIColor? = nil) -> UIView {
        let v = UIView()
        if let color = color {
            v.backgroundColor = color
        } else {
            v.backgroundColor = randomColor()
        }
        return v
    }
    
    func getLabel(_ text: String = "") -> UILabel {
        let v = UILabel()
        v.text = text
        v.textColor = randomColor()
        v.backgroundColor = randomColor()
        return v
    }
    
    func randomColor() -> UIColor {
        let red = CGFloat(arc4random()%256)/255.0
        let green = CGFloat(arc4random()%256)/255.0
        let blue = CGFloat(arc4random()%256)/255.0
        let c = UIColor(red: red, green: green, blue: blue, alpha: 0.7)
        return c
    }
    
    func random<T>(array: [T]) -> T {
        let index = arc4random_uniform(UInt32(array.count))
        return array[Int(index)]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func randomViewColor(view: UIView) {
        view.subviews.forEach { (v) in
            v.backgroundColor = self.randomColor()
            self.randomViewColor(view: v)
        }
    }

}
