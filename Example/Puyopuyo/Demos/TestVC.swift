//
//  TestVC.swift
//  Puyopuyo_Example
//
//  Created by J on 2021/8/30.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Puyopuyo
import UIKit

class TestVC: BaseVC {
    override func configView() {
//        demo1().attach(vRoot)
//        demo2().attach(vRoot)
//        demo3().attach(vRoot)
//        demo4().attach(vRoot)
//        demo5().attach(vRoot)
    }
    
    func demo5() -> UIView {
        HBox().attach {
            UILabel().attach($0)
                .text("f_f")
                .size(100, 100)
            
            UILabel().attach($0)
                .text("w_r")
            
            UILabel().attach($0)
                .text("w_r")
        }
        .padding(all: 10)
        .format(.round)
        .width(.fill)
        .view
    }
    
    func demo4() -> UIView {
        HBox().attach {
            UILabel().attach($0)
                .text("f_f")
                .size(100, 100)
            
            UILabel().attach($0)
                .text("w_r")
                .size(.wrap, .fill)
            
            UILabel().attach($0)
                .text("f_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskd")
                .numberOfLines(0)
                .size(.fill, .wrap)
            UILabel().attach($0)
                .text("f_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskd")
                .numberOfLines(0)
                .size(.fill, .wrap)
        }
        .padding(all: 10)
        .view
    }
    
    func demo3() -> UIView {
        HBox().attach {
            UILabel().attach($0)
                .text("f_f")
                .size(100, 100)
            
            UILabel().attach($0)
                .text("w_r")
                .size(.wrap, .fill)
            
            UILabel().attach($0)
                .text("f_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskd")
                .numberOfLines(0)
                .size(.fill, .wrap)
        }
        .width(.fill)
        .padding(all: 10)
        .view
    }
    
    func demo2() -> UIView {
        HBox().attach {
            UILabel().attach($0)
                .numberOfLines(0)
                .text("asdkjfhalskdjflakjsdflkajsdasdkjfhalskdjflakjsdflkajsdasdkjfhalskdjflakjsdflkajsdasdkjfhalskdjflakjsdflkajsdasdkjfhalskdjflakjsdflkajsd")
            
            UILabel().attach($0)
                .text("stay")
                .size(.wrap(priority: 10), .fill)
        }
        .view
    }
    
    func demo1() -> UIView {
        let text = State("")
        return VBox().attach {
            UITextField().attach($0)
                .onText(text)
                .size(.fill, 40)
           
            HBox().attach($0) {
                UILabel().attach($0)
                    .numberOfLines(0)
                    .size(100, .wrap)
                    .text(text.map { "F_W:\($0)" })
               
                UILabel().attach($0)
                    .numberOfLines(0)
                    .size(.wrap, 40)
                    .text(text.map { "W_F:\($0)" })
               
                UILabel().attach($0)
                    .numberOfLines(0)
                    .size(.wrap(priority: 11), .wrap)
                    .text(text.map { "W_W:\($0)" })
               
                UILabel().attach($0)
                    .numberOfLines(0)
                    .size(.wrap(priority: 10), .fill)
                    .text(text.map { "W_R:\($0)" })
               
                UILabel().attach($0)
                    .numberOfLines(0)
                    .size(.fill, .wrap)
                    .text(text.map { "R_W:\($0)" })
            }
            .size(.fill, 100)
            .justifyContent(.center)
        }
        .size(.fill, .wrap)
        .view
    }
    
    override func shouldRandomColor() -> Bool {
        true
    }
}
