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
    
    var styleSheet: StyleSheet {
        if #available(iOS 13.0, *) {
            return StyleSheet(styles: [
                Styles.cornerRadius(10),
                Styles.clipToBounds(true),
                UIFont.systemFont(ofSize: 16),
                TextColorStyle(value: .black),
                Styles.bgColor(.brown),
                ImageStyle(value: .checkmark),
            ])
        } else {
            return StyleSheet(styles: [])
        }
    }
    
    override func configView() {
        
        vRoot.attach() {
            
            UIButton().attach($0)
                .title("ripple", state: .normal)
                .styleSheet(self.styleSheet.combine([
                    TapRippleStyle()
                ]))
                .onTap(to: self, { (self, g) in
                    print("ripple")
                })
                .size(200, 50)
            
            UIButton().attach($0)
                .title("Cover", state: .normal)
                .styleSheet(self.styleSheet.combine([
                    TapCoverStyle(),
                ]))
                .onTap(to: self, { (self, _) in
                    print("cover")
                })
                .size(200, 50)
            
            Label("scale").attach($0)
                .onTap(to: self, { (self, _) in
                    print("scale")
                })
                .size(200, 50)
                .styleSheet(self.styleSheet.combine([
                    TapScaleStyle()
                ]))
            
            Label("ripple + Cover + scale").attach($0)
                .size(200, 50)
                .onTap(to: self, { (self, _) in
                    print("ripple + cover + scale")
                })
                .styleSheet(self.styleSheet.combine([
                    TapCoverStyle(),
                    TapRippleStyle(color: UIColor.red.withAlphaComponent(0.5)),
                    TapScaleStyle()
                ]))
        }
        .styles([
            TapRippleStyle()
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
