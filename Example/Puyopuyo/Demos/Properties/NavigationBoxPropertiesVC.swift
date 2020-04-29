//
//  NavibationBoxPropertiesVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/12/15.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Puyopuyo
import UIKit

class NavigationBoxPropertiesVC: BaseVC {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = min(44, max(0, 44 - scrollView.contentOffset.y))
        navHeight.input(value: .fix(height))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NavigationBox(
            navBar: {
                NavBar(title: "Nav Bar").attach()
                    .height(self.navHeight.asOutput().distinct())
                    .onEventProduced(to: self) { s, _ in
                        s.navigationController?.popViewController(animated: true)
                    }
                    .view
            }, body: {
                DemoScroll(
                    builder: {
                        self.color().attach($0)
                        self.height().attach($0)
                        self.visible().attach($0)
                        self.alpha().attach($0)
                        self.avoid().attach($0)
                        
                        UIView().attach($0)
                            .size(.fill, 200)
                    }
                )
                .attach()
                .attach {
                    $0.delegate = self
                }
                .view
            }
        )
        .attach(vRoot)
        .viewState(navState)
    }

//    override func configView() {
//        DemoScroll(
//            builder: {
//                self.color().attach($0)
//                self.height().attach($0)
//                self.visible().attach($0)
//                self.alpha().attach($0)
//                self.avoid().attach($0)
//            }
//        )
//        .attach(vRoot)
//        .size(.fill, .fill)
//    }

    func color() -> UIView {
        return DemoView<UIColor>(
            title: "nav color",
            builder: {
                UIView().attach($0).view
            },
            selectors: [
                Selector(desc: "white", value: .white),
                Selector(desc: "gray", value: .lightGray),
                Selector(desc: "red", value: .red),
                Selector(desc: "blue", value: .blue),
            ]
        )
        .attach()
        .onEventProduced(to: self) { s, x in
            s.navState.value.backgroundColor = x
        }
        .view
    }

    func height() -> UIView {
        return DemoView<SizeDescription>(
            title: "nav height",
            builder: {
                UIView().attach($0).view
            },
            selectors: [
                Selector(desc: "44", value: .fix(44)),
                Selector(desc: "64", value: .fix(64)),
                Selector(desc: "84", value: .fix(84)),
                Selector(desc: "94", value: .fix(94)),
                Selector(desc: ".wrap", value: .wrap),
            ]
        )
        .attach()
        .onEventProduced(to: self) { s, x in
            s.navHeight.value = x
        }
        .view
    }

    func avoid() -> UIView {
        return DemoView<Bool>(
            title: "avoid nav height",
            builder: {
                UIView().attach($0).view
            },
            selectors: [
                Selector(desc: "true", value: true),
                Selector(desc: "false", value: false),
            ]
        )
        .attach()
        .onEventProduced(to: self) { s, x in
            s.navState.value.bodyAvoidNavBar = x
        }
        .view
    }

    func alpha() -> UIView {
        return DemoView<CGFloat>(
            title: "alpha",
            builder: {
                UIView().attach($0).view
            },
            selectors: [
                Selector(desc: "0", value: 0),
                Selector(desc: "0.2", value: 0.2),
                Selector(desc: "0.5", value: 0.5),
                Selector(desc: "0.7", value: 0.7),
                Selector(desc: "1", value: 1),
            ]
        )
        .attach()
        .onEventProduced(to: self) { s, x in
            s.navState.value.alpha = x
        }
        .view
    }

    func visible() -> UIView {
        return DemoView<Visibility>(
            title: "nav height",
            builder: {
                UIView().attach($0).view
            },
            selectors: [
                Selector(desc: "gone", value: .gone),
                Selector(desc: "visble", value: .visible),
                Selector(desc: "invisible", value: .invisible),
            ]
        )
        .attach()
        .onEventProduced(to: self) { s, x in
            s.navState.value.visible = x
        }
        .view
    }
}
