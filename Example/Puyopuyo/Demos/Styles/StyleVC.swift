//
//  StyleVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/9/28.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Puyopuyo

class StyleVC: BaseVC {

    override func configView() {
        vRoot.attach() {
            UIButton().attach($0)
                .title("ripple", state: .normal)
                .styles([
                    Styles.cornerRadius(10),
                    TapRippleStyle<UIView>()// 有问题
                ])
                .onTap(to: self, { (self, g) in
                    print("ripple")
                })
                .size(200, 50)
            
            UIButton().attach($0)
                .title("Cover", state: .normal)
                .styles([
                    Styles.cornerRadius(10),
                    TapCoverStyle<UIView>(),
                ])
                .onTap(to: self, { (self, _) in
                    print("cover")
                })
                .size(200, 50)
            
            Label("ripple + Cover").attach($0)
                .size(200, 50)
                .onTap(to: self, { (self, _) in
                    print("ripple + cover")
                })
                .styles([
                    Styles.cornerRadius(10),
                    Styles.clipToBounds(true),
                    TapCoverStyle<UIView>(),
                    TapRippleStyle<UIView>(color: UIColor.red.withAlphaComponent(0.5))
                ])
        }
        .styles([
            TapRippleStyle<UIView>()
        ])
        .space(4)
        .padding(all: 10)
        .justifyContent(.center)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    override func shouldRandomColor() -> Bool {
        return false
    }
}
