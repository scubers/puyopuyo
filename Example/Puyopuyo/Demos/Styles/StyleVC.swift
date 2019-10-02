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
        return StyleSheet(styles: [
            (\UIView.layer.cornerRadius).getStyle(with: 10),
            (\UIView.clipsToBounds).getStyle(with: true),
            (\UIView.backgroundColor).getStyle(with: .brown),
            (\UIView.layer.borderWidth).getStyle(with: 1),
            (\UIView.layer.borderColor).getStyle(with: UIColor.purple.cgColor),
            (\UIView.py_measure.size).getStyle(with: Size(width: .fix(200), height: .fix(50))),
            UIFont.systemFont(ofSize: 16),
            TextColorStyle(value: .black, state: .normal),
            TextColorStyle(value: .red, state: .highlighted),
            TapSelectStyle(animated: true)
        ])
    }
    
    var selectedSheet: StyleSheet {
        return styleSheet.combine([
            (\UIView.backgroundColor).getStyle(with: .blue),
            TapSelectStyle(animated: true)
        ])
    }
    
    override func configView() {
        
        vRoot.attach() {
            
            UIButton().attach($0)
                .title("normal", state: .normal)
                .styleSheet(self.styleSheet.combine([
                    
                ]))
            
            UIButton().attach($0)
                .title("ripple", state: .normal)
                .styleSheet(self.styleSheet.combine([
                    TapRippleStyle()
                ]))
                .styleSheet(self.selectedSheet, selected: true)
                .onTap(to: self, { (self, g) in
                    print("ripple")
                })
            
            UIButton().attach($0)
                .title("Cover", state: .normal)
                .styleSheet(self.styleSheet.combine([
                    TapCoverStyle(),
                ]))
                .styleSheet(self.selectedSheet, selected: true)
                .onTap(to: self, { (self, _) in
                    print("cover")
                })
            
            Label("scale").attach($0)
                .onTap(to: self, { (self, _) in
                    print("scale")
                })
                .styleSheet(self.selectedSheet, selected: true)
                .styleSheet(self.styleSheet.combine([
                    TapScaleStyle()
                ]))
            
            Label("ripple + Cover + scale").attach($0)
                .onTap(to: self, { (self, _) in
                    print("ripple + cover + scale")
                })
                .styleSheet(self.selectedSheet, selected: true)
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
