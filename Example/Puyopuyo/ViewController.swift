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
    
    func testLink() {
        VLine().attach(view, wrap: false) {
            
//            $0.backgroundColor = self.randomColor()
            
//            self.getLabel("1")
//                .attach($0)
//
//            self.getLabel("2")
//                .attach($0)
//
//            self.getLabel("333333")
//                .attach($0)
            
            HLine().attach($0, wrap: false) {
                
                self.getLabel("1").attach($0)
                self.getLabel("2").attach($0)
                self.getLabel("3").attach($0)
                self.getLabel("4").attach($0)
                self.getLabel("5").attach($0)
                self.getLabel("6").attach($0)
                
            }
            .size(main: .wrap, cross: .ratio(1))
//            .padding(all: 10)
//            .size(main: .wrap, cross: .wrap)
            .formation(.sides)
            .crossAxis(.center)
            .space(10)
//            .reverse(true)
            /*
            HLine().attach($0, wrap: false) {
                
                VLine().attach($0) {
                    self.getLabel("1").attach($0)
                    self.getLabel("2").attach($0)
                    self.getLabel("3").attach($0)
                }
                .size(main: .wrap, cross: .ratio(1))
                .formation(.sides)
                
                VLine().attach($0) {
                    self.getLabel("1").attach($0)
                    self.getLabel("2").attach($0)
                    self.getLabel("3").attach($0)
                }
                .size(main: .wrap, cross: .ratio(1))
                .formation(.center)
                
                VLine().attach($0) {
                    self.getLabel("1").attach($0)
                    self.getLabel("2").attach($0)
                    self.getLabel("3").attach($0)
                }
                .size(main: .wrap, cross: .ratio(1))
                .formation(.center)
                .reverse(true)
            }
            .crossAxis(.backward)
            .formation(.sides)
            .padding(all: 20)
            .size(main: .fixed(100), cross: .ratio(1))
            */
        }
        .crossAxis(.center)
        .padding(start: 50, forward: 5)
        .space(10)
//        .reverse(true)
        .size(main: .ratio(1), cross: .ratio(1))
    }
    
    func testLabels() {
        let line = Line()
        line.layout.direction = .y
//        line.layout.formation = .center
        line.layout.crossAxis = .center
        line.layout.size = Size(main: .wrap, cross: .wrap)
        line.layout.padding = Edges(start: 4, end: 4, forward: 4, backward: 4)
        line.backgroundColor = randomColor()
        line.layout.space = 10
        line.frame = view.bounds
        view.addSubview(line)
        
        var v1 = getLabel("1")
        v1.py_measure.size = Size(main: .wrap, cross: .wrap)
        line.addSubview(v1)

        v1 = getLabel("2")
        v1.py_measure.size = Size(main: .wrap, cross: .wrap)
        line.addSubview(v1)
        
        v1 = getLabel("abcdefghijklmnopqlstuvwxyzabcdefghijklmnopqlstuvwxyz")
        //        v1.py_measure.size = Size(main: Ratio(1), cross: (60))
        v1.py_measure.size = Size(main: .wrap, cross: .fixed(100))
        v1.numberOfLines = 0
        line.addSubview(v1)
        
        return;

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            UIView.animate(withDuration: 0.5, animations: {
                line.layout.direction = .x
                line.layout.reverse = true
                line.setNeedsLayout()
                line.layoutIfNeeded()
            })
        }
    }
    
    func testWrap() {
        let line = Line()
        line.layout.direction = .y
        line.layout.formation = .center
        line.layout.crossAxis = .center
        line.layout.size = Size(main: .fixed(300), cross: .wrap)
        line.layout.padding = Edges(start: 4, end: 4, forward: 4, backward: 4)
//        line.layout.padding = Edges(start: 15, end: 15, forward: 15, backward: 15)
        line.backgroundColor = randomColor()
        line.layout.space = 10
        line.frame = view.bounds
        view.addSubview(line)
        
        var v1 = getView()
//        v1.py_measure.size = Size(main: Ratio(1), cross: (60))
        v1.py_measure.size = Size(main: .fixed(60), cross: .fixed(60))
        line.addSubview(v1)
        
        v1 = getView()
        v1.py_measure.size = Size(main: .fixed(60), cross: .fixed(80))
//        v1.py_measure.ignore = true
        line.addSubview(v1)
//
        v1 = getView()
        v1.py_measure.size = Size(main: .fixed(60), cross: .fixed(100))
        line.addSubview(v1)
        
        return;
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            line.layout.direction = .x
            line.layout.formation = .sides
            
            v1.py_measure.ignore = true
            v1 = self.getView()
            v1.py_measure.size = Size(main: .fixed(60), cross: .fixed(120))
            line.addSubview(v1)
//            line.layout.space = 30
//            v1.py_measure.margin.start = 15
//            v1.py_measure.margin.end = 15
//            v1.py_measure.margin.backward = 15
//            v1.py_measure.margin.forward = 15
//            v1.py_measure.size.cross = (50)
            line.setNeedsLayout()
            UIView.animate(withDuration: 0.5, animations: {
                line.layoutIfNeeded()
            })
        }
    }
    
    func testVLine() {
        let line = VLine()
        line.layout.crossAxis = .center
        line.layout.size = Size(main: .fixed(400), cross: .fixed(view.bounds.width))
        line.layout.padding = Edges(start: 10, end: 20, forward: 30, backward: 40)
        line.frame.origin = CGPoint(x: 0, y: 0)
        line.backgroundColor = randomColor()
        line.layout.space = 10
        view.addSubview(line)
        
        let v1 = getView()
        v1.py_measure.size = Size(main: .fixed(100), cross: .fixed(100))
        line.addSubview(v1)
        
        let v2 = getView()
        v2.py_measure.size = Size(main: .fixed(50), cross: .fixed(50))
        v2.py_measure.aligment = .forward
        v2.py_measure.margin = Edges(start: 20, end: 25, forward: 0, backward: 0)
        line.addSubview(v2)
        
        let v3 = getView()
        v3.py_measure.size = Size(main: .fixed(80), cross: .fixed(80))
        v3.py_measure.aligment = .backward
        line.addSubview(v3)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIView.animate(withDuration: 1) {
                v1.py_measure.aligment = .backward
                v2.py_measure.aligment = .center
                v3.py_measure.aligment = .forward
                line.setNeedsLayout()
                line.layoutIfNeeded()
            }
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

