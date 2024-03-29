//
//  TestVC.swift
//  Puyopuyo_Example
//
//  Created by J on 2021/8/30.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Puyopuyo
import SnapKit
import TangramKit
import UIKit
import YogaKit

class MyView: UIView {
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return .init(width: 400, height: 20)
    }
}

class MyCell: HBox, Stateful {
    struct ViewState {
        var title: String?
        var desc: String
        var image: String?
    }
    
    let state = State(ViewState(desc: ""))
    
    override func buildBody() {
        attach {
            UIImageView().attach($0)
                .size(80, 80)
                .image(binder.image.then { downloadImage(url: $0) })
                .clipToBounds(true)
                .cornerRadius(6)
            
            VGroup().attach($0) {
                UILabel().attach($0)
                    .text(binder.title)
                    .fontSize(18, weight: .bold)
                
                UILabel().attach($0)
                    .text(binder.desc)
                    .textColor(UIColor.secondaryLabel)
                    .fontSize(14)
            }
            .alignment(.vertCenter(-0.5))
            .space(4)
        }
        .padding(all: 8)
        .space(8)
        .borders([.color(.gray), .thick(1)])
        .backgroundColor(.white)
        .style(ShadowStyle())
    }
}

extension Bool {
    var visibleOrGone: Visibility { self ? .visible : .gone }
    var visibleOrNot: Visibility { self ? .visible : .invisible }
}

class TestVC: BaseViewController {
    let text = State("")
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.attach {
            UIView().attach($0)
                .size(50, 50)
            
            HBox().attach($0) {
                UILabel().attach($0)
                    .text("1")
                    .textAlignment(.center)
                    .size(50, 50)
                
                UILabel().attach($0)
                    .text("2")
                    .textAlignment(.center)
                    .margin(leading: 20, trailing: 15)
                    .size(50, 50)
                
                UILabel().attach($0)
                    .text("3")
                    .textAlignment(.center)
                    .size(50, 50)
            }
            .format(.leading)
            .alignment(.center)
            .size(400, 200)
            .padding(leading: 10)
            .diagnosis("99")
        }
        
        Util.randomViewColor(view: view)
    }
    
    func testCrossConflictingExtreme() -> UIView {
        VBox().attach {
            let state = State<Float>(0)
            let content = state.map { Int(100 * $0) }.map { (0 ..< $0).map(\.description).joined() }
            let content1 = state.map { Int(50 * $0) }.map { (0 ..< $0).map(\.description).joined() }
            UISlider().attach($0)
                .width(.fill)
                .set(\.value, state.value)
                .onControlEvent(.valueChanged, Inputs { state.value = $0.value })
            
            HBox().attach($0) {
                UILabel().attach($0)
//                        .size(.wrap(shrink: 1), .wrap)
                    .width(.fill)
                    .text(content)
                    .numberOfLines(0)
                UIView().attach($0)
                    .size(.aspectRatio(1), .fill)
                UILabel().attach($0)
                    .width(.fill)
//                        .size(.wrap(shrink: 1), .wrap)
                    .text(content1)
                    .numberOfLines(0)
                
                UIView().attach($0)
                    .size(50, 50)
            }
            .justifyContent(.center)
            .size(.fill, .wrap)
        }
        .animator(Animators.default)
        .format(.center)
        .size(.fill, .fill)
        .view
    }
    
    func testFlexSize() -> UIView {
        let isOn = State(false)
        let direction = isOn.map { $0 ? Direction.vertical : .horizontal }
            
        return VBox().attach {
            UISwitch().attach($0)
                .isOn(isOn)
                
            LinearBox().attach($0) {
                for _ in 0 ..< 5 {
                    UIView().attach($0)
                        .size(Size.flex(main: .fill, cross: .fix(50), axis: direction))
                }
            }
            .space(5)
            .padding(all: 10)
            .direction(direction)
            .size(.fill, .fill)
            .animator(Animators.default)
        }
        .padding(view.py_safeArea())
        .size(.fill, .fill)
        .view
    }
    
    func testGroup() -> UIView {
        VBox().attach {
            let state = State(true)
            let trigger = State(0)
            
            VFlowGroup().attach($0) {
                UISwitch().attach($0).isOn(state)
                UIButton().attach($0)
                    .text("Increase")
                    .onControlEvent(.touchUpInside, Inputs { _ in
                        trigger.value += 1
                    })
            }
            
            Label("header").attach($0)
                .size(.fill, 50)
            
            VGroup().attach($0) {
                HGroup().attach($0) {
                    for i in 0 ..< 10 {
                        Label("\(i)\(i)").attach($0)
                            .visibility(state.map { (!$0 || i != 1).visibleOrGone })
                    }
                }
                .padding(all: 10)
                .visibility(state.binder.visibleOrGone)
                
                HGroup().attach($0) {
                    HGroup().attach($0) {
                        Label("1").attach($0)
                        Label("2").attach($0)
                    }
                    .format(.between)
                    .width(.fill)
                    
                    HGroup().attach($0) {
                        Label("3").attach($0)
                        Label("4").attach($0)
                    }
                    .format(.between)
                    .width(.fill)
                }
                .width(.fill)
                
                VGroup().attach($0) { v in
                    trigger.skip(1).safeBind(to: v) { v, _ in
                        UIView().attach(v)
                            .size(50, 50)
                            .backgroundColor(Util.randomColor())
                            .userInteractionEnabled(true)
                            .onTap {
                                $0.view?.removeFromSuperBox()
                            }
                    }
                }
                .visibility(state.binder.visibleOrNot)
                
                FlowGroup().attach($0) {
                    FlowGroup().attach($0) {
                        for i in 11 ..< 20 {
                            Label("\(i)").attach($0)
                        }
                    }
                    .arrangeCount(3)
                    .direction(.y)
                    .space(5)
                    
                    for i in 30 ..< 40 {
                        Label("\(i)").attach($0)
                    }
                    
                    VFlow().attach($0) {
                        for i in 100 ..< 110 {
                            Label(i.description).attach($0)
                        }
                        
                        HGroup().attach($0) {
                            for i in 200 ..< 210 {
                                Label(i.description).attach($0)
                            }
                        }
                    }
                }
                .direction(.y)
                .space(5)
                .padding(all: 10)
                
                ZGroup().attach($0) {
                    UIView().attach($0)
                        .size(.ratio(1), .ratio(1))
                    UIView().attach($0)
                        .size(.ratio(0.5), .ratio(0.5))
                    UIView().attach($0)
                        .size(.ratio(0.2), .ratio(0.2))
                }
                
                .size(100, 100)
            }
            .size(.fill, .fill)
            
            Label("footer").attach($0)
                .size(.fill, 50)
        }
        .animator(Animators.default)
        .size(.fill, .fill)
        .padding(all: 10)
        .margin(view.py_safeArea())
        .view
    }
    
    func systemColorTest() -> UIView {
        view.backgroundColor = .black
        return VBox().attach(view) {
            HBox().attach($0) {
                UILabel().attach($0)
                    .backgroundColor(UIColor.systemBackground)
                    .text("systemBackground")
                    .size(.fill, 50)
                UILabel().attach($0)
                    .backgroundColor(UIColor.secondarySystemBackground)
                    .text("secondarySystemBackground")
                    .size(.fill, 50)
                
                UILabel().attach($0)
                    .backgroundColor(UIColor.tertiarySystemBackground)
                    .text("tertiarySystemBackground")
                    .size(.fill, 50)
            }
            .width(.fill)
            
            HBox().attach($0) {
                UILabel().attach($0)
                    .backgroundColor(UIColor.systemGroupedBackground)
                    .text("systemGroupedBackground")
                    .size(.fill, 50)
                UILabel().attach($0)
                    .backgroundColor(UIColor.secondarySystemGroupedBackground)
                    .text("secondarySystemGroupedBackground")
                    .size(.fill, 50)
                
                UILabel().attach($0)
                    .backgroundColor(UIColor.tertiarySystemGroupedBackground)
                    .text("tertiarySystemGroupedBackground")
                    .size(.fill, 50)
            }
            .width(.fill)
            
            HBox().attach($0) {
                UILabel().attach($0)
                    .backgroundColor(UIColor.systemFill)
                    .text("systemFill")
                    .size(.fill, 50)
                UILabel().attach($0)
                    .backgroundColor(UIColor.secondarySystemFill)
                    .text("secondarySystemFill")
                    .size(.fill, 50)
                
                UILabel().attach($0)
                    .backgroundColor(UIColor.tertiarySystemFill)
                    .text("tertiarySystemFill")
                    .size(.fill, 50)
                
                UILabel().attach($0)
                    .backgroundColor(UIColor.quaternarySystemFill)
                    .text("quaternarySystemFill")
                    .size(.fill, 50)
            }
            .width(.fill)
        }
        .padding(view.py_safeArea())
        .size(.fill, .fill)
        .view
    }
    
    func formatTest() -> UIView {
        let state = State("")
        return HBox().attach {
            state.safeBind(to: $0) { this, _ in
                UIView().attach(this)
                    .backgroundColor(Util.randomColor())
                    .size(50, 50)
//                        .margin(left: 10)
            }
        }
        .onTap {
            state.input(value: "")
        }
        .alignment(.center)
        .format(.between)
        .space(10)
        .padding(all: 10)
        .size(200, .wrap)
        .view
    }
    
    func jkProblem1() -> UIView {
        VBox().attach {
            let state = State(false)
            
            UISwitch().attach($0)
                .isOn(state)
            
            VBox().attach($0) {
                Label(".fill, 50").attach($0)
                    .size(.fill, 50)
                
                Label(".fill, .fill 正方形").attach($0)
                    .width(.fill)
                    .height(.aspectRatio(1))
                    .visibility(state.binder.visibleOrGone)
                
                Label(".fill, .wrap Some content").attach($0)
                    .size(.fill, .wrap)
                    .visibility(state.binder.visibleOrGone)
                
                Label(".fill, .fill MarksView").attach($0)
                    .size(.fill, .fill)
                    .visibility(state.binder.visibleOrNot)
                
                Label(".wrap, .wrap BottomView").attach($0)
            }
            .justifyContent(.center)
            .size(200, 400)
            .padding(all: 10)
            .space(5)
            .alignment(.center)
        }
        .size(.fill, .fill)
        .view
    }
    
    func crossConflictView() -> UIView {
        VBox().attach {
            let progress = State<CGFloat>(0)
            HBox().attach($0) {
                Label("").attach($0)
                    .text(progress.map { v -> String in
                        let total = Int(v * 50)
                        return (0 ..< total).map { "\($0)" }.joined(separator: "")
                    })
//                    .size(.wrap(shrink: 1, grow: 1), .fill)
                    .width(.wrap(shrink: 1))
                    .height(.fill)
                
                Label("").attach($0)
                    .text(progress.map { v -> String in
                        let total = Int(v * 100)
                        return (0 ..< total).map { "\($0)" }.joined(separator: "")
                    })
                    .width(.wrap(shrink: 2))

//                UIView().attach($0)
//                    .size(.fill, .aspectRatio(2))
            }
            .padding(all: 10)
            .justifyContent(.center)
            .format(.between)
            .size(.fill, .wrap)
            
            UISlider().attach($0)
                .width(.fill)
                .onControlEvent(.valueChanged, Inputs {
                    progress.value = CGFloat($0.value)
                })
        }
        .width(.fill)
        .view
    }
    
    func tgTestView() -> UIView {
        UIView().attach {
            TGLinearLayout(.vert).attach($0) {
                $0.tg_size(width: .fill, height: .fill)
                $0.tg_padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                    
                TGLinearLayout(.horz).attach($0) {
                    $0.tg_size(width: .fill, height: 70)
                    $0.tg_padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                            
                    UILabel().attach($0) {
                        $0.tg_size(width: .wrap, height: .fill)
                        $0.tg_width.equal($0.tg_height)
                    }
                    .text("abc")
                }
            }
        }
        .size(.fill, .fill)
        .view
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
                    .size(.wrap, .aspectRatio(2 / 1))
//                    .aspectRatio(2 / 1)
                    .alignment([.top, .right])
            }
            .padding(all: 10)
            .height(.aspectRatio(1))
//            .aspectRatio(1)
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
                .alignment(.center(-0.8, 0.8))
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
                ListRecycleSection(items: [].asOutput(), cell: { _, _ in
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
                    .set(\.lineBreakMode, .byClipping)

                UILabel().attach($0)
                    .numberOfLines(0)
                    .text(state)
                    .width(.wrap(max: 200, shrink: 1))
                    .observe(\.bounds, input: label2Rect)
                    .margin(left: 10)
                    .set(\.lineBreakMode, .byClipping)
                    .height(.wrap(max: 100))
//                    .aspectRatio(1)
                    .width(.aspectRatio(1 / 1))
                
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
                .margin(left: 10, right: 10)
                .height(10)
                
            UILabel().attach($0)
                .text("Stay")
//                .width(.wrap)
        }
//        .space(10)
//        .padding(all: 10)
        .height(.wrap)
        .width(.fill)
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
                    .size(.wrap, 50)
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
}

class MySwitch: ZBox {
    override func buildBody() {
        let state = State(false)
        attach {
            UIView().attach($0)
                .size(30, 30)
                .cornerRadius(15)
                .backgroundColor(.black)
                .alignment(state.map { $0 ? .right : .left })
                .animator(ExpandAnimator())
        }
        .onTap {
            state.value = !state.value
        }
    }
}
