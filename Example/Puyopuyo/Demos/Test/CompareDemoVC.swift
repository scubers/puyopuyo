//
//  CompareDemoVC.swift
//  Puyopuyo_Example
//
//  Created by 王俊仁 on 2021/1/5.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Puyopuyo
import SnapKit
import UIKit

class CompareDemoVC: BaseVC {
    override func configView() {
        VBox().attach(vRoot) {
            puyopuyo().attach($0)

            UIView().attach($0) {
                _ = autolayout($0)
            }
            .width(.fill)
            .height(40)

            UIView().attach($0) {
                _ = snapkit($0)
            }
            .width(.fill)
            .height(40)

            Util.randomViewColor(view: $0)
        }
        .justifyContent(.center)
        .format(.center)
        .size(.fill, .fill)
        .space(20)
        .padding(all: 20)
    }

//    override func shouldRandomColor() -> Bool {
//        true
//    }

    private func puyopuyo() -> UIView {
        HBox().attach {
            UILabel().attach($0)
                .text("使用新框架")

            UILabel().attach($0)
                .text("label B")
        }
        .space(10)
        .padding(all: 5)
        .width(.fill)
        .view
    }

    private func autolayout(_ superView: UIView) -> UIView {
        let view = superView
        let labelA = UILabel()
        let labelB = UILabel()

        labelA.translatesAutoresizingMaskIntoConstraints = false
        labelB.translatesAutoresizingMaskIntoConstraints = false
        labelA.text = "iOS原生"
        labelB.text = "label B"

        view.addSubview(labelA)
        view.addSubview(labelB)

        view.addConstraint(NSLayoutConstraint(item: labelA,
                                              attribute: .left,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .left,
                                              multiplier: 1,
                                              constant: 5))
        view.addConstraint(NSLayoutConstraint(item: labelB,
                                              attribute: .left,
                                              relatedBy: .equal,
                                              toItem: labelA,
                                              attribute: .right,
                                              multiplier: 1,
                                              constant: 10))
        view.addConstraint(NSLayoutConstraint(item: labelA,
                                              attribute: .centerY,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .centerY,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: labelB,
                                              attribute: .centerY,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .centerY,
                                              multiplier: 1,
                                              constant: 0))
        
        return view
    }

    private func snapkit(_ superView: UIView) -> UIView {
        let view = superView
        let labelA = UILabel()
        let labelB = UILabel()

        labelA.text = "基于iOS原生的封装"
        labelB.text = "label B"

        view.addSubview(labelA)
        view.addSubview(labelB)

        labelA.snp.makeConstraints { m in
            m.left.equalToSuperview().offset(5)
            m.centerY.equalToSuperview()
        }

        labelB.snp.makeConstraints { m in
            m.left.equalTo(labelA.snp.right).offset(10)
            m.centerY.equalToSuperview()
        }

        return view
    }
}
