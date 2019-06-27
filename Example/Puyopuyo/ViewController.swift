//
//  ViewController.swift
//  Puyopuyo
//
//  Created by Jrwong on 06/22/2019.
//  Copyright (c) 2019 Jrwong. All rights reserved.
//

import UIKit
import Puyopuyo

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
//        testVLine()
//        testWrap()
//        testLabels()
     
        testLink()
        
        randomViewColor(view: view)
    }
    
    func testSizeThatFits() -> Line {
        return
            VLine().attach() {
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
        VLine().attach(view, wrap: false) {
            
//            $0.backgroundColor = self.randomColor()
            
//            self.getLabel("1").attach($0)
//
//            self.getLabel("2")
//                .attach($0)
//
//            self.getLabel("333333333333")
//                .attach($0)
            
            
            HLine().attach($0, wrap: false) {
                label =
                self.getLabel("1111").attach($0)
                    .view
//                    .margin(left: 5, right: 20)
                self.getLabel("2222").attach($0)
                    .aligment([.bottom])
//                    .margin(left: 30, right: 10)
                self.getLabel("扥扥零担疯了").attach($0)
//                    .margin(left: 30, right: 10)
            }
//            .size(width: .ratio(1), height: .fixed(100))
            .size(.fill, .wrap)
            .space(10)
            .reverse(true)
            .formation(.leading)
//            .padding(left: 30, right: 50)
//            .formation(.trailing)
//            .reverse(true)
            
            /*
            VLine().attach($0) {
                self.getLabel("1111").attach($0)
            }
            .margin(top: 10)
            .crossAxis(.left)
            .size(width: .ratio(1), height: .fixed(50))
            
            HLine().attach($0, wrap: false) {
                
                VLine().attach($0) {
                    self.getLabel("1").attach($0)
                    self.getLabel("2").attach($0)
                    self.getLabel("3").attach($0)
                }
                .size(width: .wrap, height: .ratio(1))
                .formation(.sides)
                
                VLine().attach($0) {
                    self.getLabel("1").attach($0)
                    self.getLabel("2").attach($0)
                    self.getLabel("3").attach($0)
                }
                .size(width: .wrap, height: .ratio(1))
                .formation(.center)
                
                VLine().attach($0) {
                    self.getLabel("1").attach($0)
                    self.getLabel("2").attach($0)
                    self.getLabel("3").attach($0)
                }
                .size(width: .wrap, height: .ratio(1))
                .formation(.center)
                .reverse(true)
            }
            .crossAxis([.top])
            .formation(.sides)
            .padding(all: 20)
            .size(width: .ratio(1), height: .fixed(150))
            */
        }
        .crossAxis([.left, .top])
        .padding(top: 50)
        .space(10)
        .size(.ratio(1), .ratio(1))
//        .reverse(true)
//        .size(width: .ratio(1), height: .fixed(100))
//        .reverse(true)
//        .size(main: .ratio(1), cross: .ratio(1))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            label?
                .attach()
                .margin(all: 10)
                .size(50, 100)
                .visible(.invisible)
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
//            label?.superview?.setNeedsLayout()
//            label?.superview?.layoutIfNeeded()
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

