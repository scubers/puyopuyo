//
//  ViewController.swift
//  Puyopuyo
//
//  Created by Jrwong on 06/22/2019.
//  Copyright (c) 2019 Jrwong. All rights reserved.
//

import UIKit
import Puyopuyo
import TangramKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
//        testVLine()
//        testWrap()
//        testLabels()
     
        testLink()
        
        randomViewColor(view: view)
    }
    
    
    func testYoga() {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let vc = StyleTestViewController()
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
    
    func testSizeThatFits() -> FlatBox {
        return
            VBox().attach() {
                self.getLabel("111").attach($0)
                self.getLabel("222").attach($0)
                self.getLabel("333").attach($0)
            }
            .space(10)
            .padding(all: 10)
            .size(.ratio(1), .wrap)
            .view
    }
    
    func testLink() {
//        let link =
        var label: UIView?
        VBox().attach(view) {
            
            HBox.attach($0) {
                label =
                self.getLabel("1111").attach($0)
//                    .height(.ratio(1))
                    .view
//                    .margin(left: 5, right: 20)
                self.getLabel("2222").attach($0)
                    .aligment([.bottom])
//                    .margin(left: 30, right: 10)
                label =
                self.getLabel("扥扥零担疯了").attach($0)
//                    .height(50)
                    .width(.ratio(10))
                    .view
            }
            .size(.fill, .wrap)
            .space(10)
            .formation(.center)
            .padding(top: 20, left: 20, bottom: 20, right: 20)
            

        }
        .justifyContent([.left, .top])
        .padding(top: 50)
        .space(10)
        .size(.ratio(1), .ratio(1))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            label?
                .attach(wrap: false)
                .height(.wrap(add: 30))
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func getView() -> UIView {
        let v = UIView()
        v.backgroundColor = randomColor()
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

