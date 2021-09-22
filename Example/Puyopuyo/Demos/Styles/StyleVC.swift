//
//  StyleVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/9/28.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Puyopuyo
import UIKit

class StyleVC: BaseVC {
    var styleSheet: StyleSheet {
        return StyleSheet(styles: [
            (\UIView.layer.cornerRadius).getStyle(with: 10),
            (\UIView.clipsToBounds).getStyle(with: true),
            (\UIView.backgroundColor).getStyle(with: Theme.accentColor),
            (\UIView.layer.borderWidth).getStyle(with: 1),
            (\UIView.py_measure.size).getStyle(with: Size(width: .fix(200), height: .fix(50))),
            UIFont.systemFont(ofSize: 16),
            TextColorStyle(value: .black, state: .normal),
            TextColorStyle(value: .white, state: .highlighted)
        ])
    }
    
    let toggle = State<Bool>(false)
    
    var selectableSheet: StyleSheet {
        return StyleSheet(styles: [
            TapSelectStyle(normal: styleSheet,
                           selected: styleSheet.combine([
                               (\UIView.backgroundColor).getStyle(with: UIColor.systemPink)
                           ]),
                           toggle: toggle.asOutput())
        ])
    }
    
    override func configView() {
        vRoot.attach {
            DemoScroll {
                UILabel().attach($0)
                    .fontSize(20, weight: .bold)
                    .text("""
                    Puyo provide a Style protocol to do some decoration works.
                    """)
                    .numberOfLines(0)
                
                UIButton().attach($0)
                    .text("normal", state: .normal)
                    .onTap(to: self) { this, _ in
                        this.toggle.value = !this.toggle.value
                    }
                    .styleSheet(styleSheet)
                
                UIButton().attach($0)
                    .text("ripple", state: .normal)
                    .styleSheet(selectableSheet.combine([
                        TapRippleStyle()
                    ]))
                    .onTap {
                        print("ripple")
                    }
                
                UIButton().attach($0)
                    .text("Cover", state: .normal)
                    .styleSheet(selectableSheet.combine([
                        TapCoverStyle()
                    ]))
                    .onTap {
                        print("cover")
                    }
                
                Label("scale").attach($0)
                    .onTap {
                        print("scale")
                    }
                    .styleSheet(selectableSheet.combine([
                        TapTransformStyle()
                    ]))
                
                Label("ripple + Cover + scale").attach($0)
                    .onTap {
                        print("ripple + cover + scale")
                    }
                    .styleSheet(selectableSheet.combine([
                        TapCoverStyle(),
                        TapRippleStyle(color: UIColor.red.withAlphaComponent(0.5)),
                        TapTransformStyle()
                    ]))
            }
            .attach($0)
            .size(.fill, .fill)
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
