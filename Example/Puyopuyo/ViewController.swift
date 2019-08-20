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

class ViewController: BaseVC {
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
        ZBox().attach(view) {
            
            HBox().attach($0) {
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
//        .justifyContent([.left, .top])
        .justifyContent([.center])
        .padding(top: 50)
        .size(.ratio(1), .ratio(1))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            label?
                .attach()
                .height(.wrap(add: 30))
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
 

}

