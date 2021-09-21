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
    let text = State("")
    override func configView() {
//        demo1().attach(vRoot)
//        demo2().attach(vRoot)
//        demo3().attach(vRoot)
//        demo4().attach(vRoot)
//        demo5().attach(vRoot)
//        demo6().attach(vRoot)
//        shrinkDeadLoopTest().attach(vRoot)
//        flowCompactTest().attach(vRoot)
        
//        zboxFillAndWrapTest().attach(vRoot)
        
//        crossAlignmentRatio().attach(vRoot)
        
//        flowRatioWrapTest().attach(vRoot)
        
//        zboxAspectRatioTest().attach(vRoot)
        
//        zboxRatioTest().attach(vRoot)
        
        let message = State(false)
        var v: UIView?
        var vv: UIView?
        
        vRoot.attach {
            MySwitch().attach($0)
                .size(100, 30)
            v = MessageView().attach($0)
                .width(.fill)
                .viewState(message.map { Message(isSelf: $0) })
                .bind(keyPath: \.regulator.animation, Animators.default)
                .view
            
            vv = UIButton(type: .contactAdd).attach($0)
                .on(message) { v, value in
                    v.layer.transform = value ? CATransform3DMakeRotation(CGFloat.pi / 4, 0, 0, 1) : CATransform3DIdentity
                }
                .view
        }
        .onTap {
//            Animators.default.animate(UIView(), size: .zero, center: .zero) {
                message.input(value: !message.value)
//                v?.layoutIfNeeded()
//            }
//            vv?.layer.transform = !message.value ? CATransform3DMakeRotation(CGFloat.pi / 4, 0, 0, 1) : CATransform3DIdentity
        }
        
//        let progress = State(CGFloat(1))
//        vRoot.attach {
//            let progress = State(CGFloat(1))
//            DemoView<CGFloat>(
//                title: "Fixed size will overflow",
//                builder: {
//                    VBox().attach($0) {
//                        HBox().attach($0) {
//                            for i in 0 ..< 10 {
//                                Label.demo(i.description).attach($0)
//                                    .size(100, 100)
//                            }
//                        }
//                        .demo()
//                        .width(Outputs.combine($0.py_boundsState(), progress).map { r, v -> SizeDescription in
//                            .fix(r.width * v)
//                        })
//                        .space(8)
//
//                        UISlider().attach($0)
//                            .bind(keyPath: \.value, progress.map(Float.init))
//                            .onEvent(.valueChanged, progress.asInput { CGFloat($0.value) })
//                            .width(.fill)
//                    }
//                    .width(.fill)
//                    .padding(all: 10)
//                    .view
//
//                },
//                selectors: [],
//                desc: ".fixed(value) size will ignore residual size, and overflow"
//            )
//            .attach($0)
//            .width(.fill)
//        }
    }
    
    func zboxRatioTest() -> UIView {
        VBox().attach {
            ZBox().attach($0) {
                Label.demo("3").attach($0)
                    .size(.ratio(1.2), .ratio(1.2))
                
                Label.demo("2").attach($0)
                    .size(.fill, .fill)
                
                Label.demo("1").attach($0)
                    .size(.ratio(0.8), .ratio(0.8))
            }
            .justifyContent([.left, .bottom])
            .size(100, 100)
        }
        .view
    }
    
    func zboxAspectRatioTest() -> UIView {
        VBox().attach {
            ZBox().attach($0) {
                Label.demo("100").attach($0)
                    .aspectRatio(2 / 1)
                    .alignment([.top, .right])
            }
            .padding(all: 10)
            .aspectRatio(1)
        }
        .view
    }
    
    func flowRatioWrapTest() -> UIView {
        VBox().attach {
            VFlow().attach($0) {
                Label.demo("1").attach($0)
                    .size(100, 50)
//                    .width(.wrap(min: 100, max: 100, shrink: 1))
//                    .height(.wrap(min: 100, shrink: 1))
                    .cornerRadius(10)
                Label.demo("2").attach($0)
                    .width(.wrap(min: 100, max: 100, shrink: 1))
                    .height(.fill)
                    .cornerRadius(10)
                
                Label.demo("3").attach($0)
                    .width(.wrap(min: 100, max: 100, shrink: 1))
                    .height(.wrap(min: 100, shrink: 1))
                    .cornerRadius(10)
            }
            .arrangeCount(2)
//            .height(.fill)
//            .width(.fill)
            .space(20)
        }
        .size(.fill, .fill)
        .justifyContent(.center)
        .padding(all: 10)
        .view
    }
    
    func crossAlignmentRatio() -> UIView {
        ZBox().attach {
            Label.demo("test").attach($0)
//                .alignment(.vertCenter(ratio: 1.5))
                .alignment(.center(x: -0.8, y: 0.8))
        }
        .size(.fill, 100)
        .view
    }
    
    func zboxFillAndWrapTest() -> UIView {
        ZBox().attach {
            UIView().attach($0)
                .backgroundColor(UIColor.black)
                .size(.ratio(2), .ratio(2))
        }
        .size(100, 100)
        .padding(all: 10)
        .view
    }
    
    func testRecycleBox() -> UIView {
        RecycleBox(
            sections: [
                DataRecycleSection(items: [].asOutput(), cell: { _, _ in
                    Label.title("")
                })
            ].asOutput()
        )
        .attach()
        .view
    }
    
    func flowCompactTest() -> UIView {
        VBox().attach {
            VFlow().attach($0) {
                for i in 0 ..< 50 {
                    Label.demo(i.description).attach($0)
                        .width(.wrap(min: 100, max: 100, shrink: 1))
                        .height(.wrap(min: 100, shrink: 1))
                        .cornerRadius(10)
//                        .size(50, 50)
                }
            }
            .arrangeCount(10)
            .height(.fill)
            .width(.fill)
            .space(20)
        }
        .size(.fill, .fill)
        .justifyContent(.center)
        .padding(all: 10)
        .view
    }
    
    func shrinkDeadLoopTest() -> UIView {
        VBox().attach {
            let state = State("sdfadsf")
            
            UITextField().attach($0)
                .size(.fill, 50)
                .onText(state)
            
            let label1Rect = State<CGRect?>(.zero)
            let label2Rect = State<CGRect?>(.zero)
            
            let container = HBox().attach($0) {
                UIView().attach($0)
                    .size(30, .fill)
                
                UILabel().attach($0)
                    .numberOfLines(0)
                    .text(state.map { "\($0)\($0)" })
                    .width(.wrap(shrink: 1))
                    .observe(\.bounds, input: label1Rect)
                    .margin(left: 10)
                    .bind(keyPath: \.lineBreakMode, .byClipping)

                UILabel().attach($0)
                    .numberOfLines(0)
                    .text(state)
                    .width(.wrap(max: 200, shrink: 1))
                    .observe(\.bounds, input: label2Rect)
                    .margin(left: 10)
                    .bind(keyPath: \.lineBreakMode, .byClipping)
                    .height(.wrap(max: 100))
                    .aspectRatio(1)
                    .diagnosis("control pad")
                    .diagnosisExtraMessage("good job")
                
                UILabel().attach($0)
                    .text("100")
                    .size(.wrap, .fill)
                
                UILabel().attach($0)
                    .text("stay")
//                    .margin(left: 10)
                    .width(.wrap(priority: 2))
            }
            .justifyContent(.center)
            .animator(Animators.default)
//            .space(10)
//            .width(500)
//            .height(100)
            .view
            
            let original = state.map { text -> String in
                let label = UILabel()
                label.text = "\(text)\(text)"
                var size = label.sizeThatFits(.zero)
                let originWidth1 = size.width
                
                label.text = text
                size = label.sizeThatFits(.zero)
                let originWidth2 = size.width
                
                let total = "total: \(originWidth1 + originWidth2)"
                let delta = "delta: \(originWidth1 + originWidth2 - 500)"
                let origin = "width1: \(originWidth1), width2: \(originWidth2), width1 / width2 = \(originWidth1 / originWidth2)"
                
                let cal1 = originWidth1 - (originWidth1 + originWidth2 - 500) / 2
                let cal2 = originWidth2 - (originWidth1 + originWidth2 - 500) / 2
                
                let cal = "calW1: \(cal1)   calW2: \(cal2)"
                return [total, delta, origin, cal].joined(separator: "\n")
            }
            
            let containerWidth = container.py_boundsState().map { rect in
                "container width: \(rect.size.width)"
            }
            
//            let oversize = Outputs.combine(label1Rect.unwrap(or: .zero), label2Rect.unwrap(or: .zero), container.py_boundsState()).map { r1, r2, r3 in
//                "total: \(r1.width + r2.width)   delta: \(r1.width + r2.width - r3.width)"
//            }
            
            let width1 = label1Rect.unwrap(or: .zero).map { rect in
                "label1 real width: \(rect.size)"
            }
            
            let width2 = label2Rect.unwrap(or: .zero).map { rect in
                "label2 real width: \(rect.size)"
            }
            
            UILabel().attach($0)
                .numberOfLines(0)
                .size(.fill, .wrap)
                .text(Outputs.combine([original, containerWidth, width1, width2]).map { $0.joined(separator: "\n\n") })
        }
        .padding(all: 20)
        .size(.fill, .fill)
        .view
    }
    
    func demo6() -> UIView {
        HBox().attach {
            UITextField().attach($0)
                .size(100, 40)
                .onText(text)
            
//            HBox().attach($0) {
                
            UILabel().attach($0)
                .text(text)
                .margin(left: 10)
                
            UILabel().attach($0)
                .text("texttexttexttexttexttext")
                .margin(left: 10, right: 10)
                
            UIView().attach($0)
                .width(.fill)
                .margin(left: 30)
                .height(10)
                
            UILabel().attach($0)
                .text("Stay")
                .width(.wrap)
//            }
        }
//        .space(10)
//        .padding(all: 10)
        .height(.wrap)
        .width(500)
        .view
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
        .width(.fill)
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
                    .text(text.map { "F_W\n\($0)" })
               
                UILabel().attach($0)
                    .numberOfLines(0)
                    .size(.wrap, 40)
                    .text(text.map { "W_F\n\($0)" })
               
                UILabel().attach($0)
                    .numberOfLines(0)
                    .size(.wrap(priority: 11), .wrap)
                    .text(text.map { "W_W\n\($0)" })
               
                UILabel().attach($0)
                    .numberOfLines(0)
                    .size(.wrap(priority: 10), .fill)
                    .text(text.map { "W_R\n\($0)" })
               
                UILabel().attach($0)
                    .numberOfLines(0)
                    .size(.fill, .wrap)
                    .text(text.map { "R_W\n\($0)" })
            }
            .size(.fill, .wrap)
            .justifyContent(.center)
        }
        .size(.fill, .wrap)
        .view
    }
    
    override func shouldRandomColor() -> Bool {
        true
    }
}

class MySwitch: ZBox {
    override func buildBody() {
        let state = State(false)
        attach {
            UIView().attach($0)
                .attach($0)
                .size(30, 30)
                .cornerRadius(15)
                .backgroundColor(.black)
                .alignment(state.map { $0 ? .right : .left })
                .bind(keyPath: \.py_measure.animation, ExpandAnimator())
        }
        .onTap {
            state.value = !state.value
        }
    }
}
