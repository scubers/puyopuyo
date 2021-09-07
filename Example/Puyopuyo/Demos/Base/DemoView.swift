//
//  DemoView.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/12/8.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Puyopuyo
import UIKit

typealias ViewBuilder = (UIView) -> UIView

class DemoView<T: Equatable>: VBox, Eventable, Stateful {
    var eventProducer = SimpleIO<T>()
    var viewState = State<T?>(nil)
    
    var title: String
    var desc: String
    var selectors: [Selector<T>]
    init(title: String, builder: @escaping ViewBuilder, selectors: [Selector<T>], selected: T? = nil, desc: String = "") {
//        self.builder = builder
        self.title = title
        self.selectors = selectors
        self.desc = desc
        super.init(frame: .zero)
        
        attach {
            Label(self.title).attach($0)
                .size(.fill, 40)
                .textAlignment(.center)
                .backgroundColor(UIColor.black.withAlphaComponent(0.2))
            
            ZBox().attach($0) {
                builder($0).attach($0)
            }
            .backgroundColor(Theme.card)
            .width(.fill)
            
            SelectionView(self.selectors, selected: selected).attach($0)
                .topBorder([.color(UIColor.black.withAlphaComponent(0.2)), .thick(Util.pixel(1))])
                .size(.fill, .wrap)
                .visibility(self.selectors.count > 0 ? .visible : .gone)
                .onEventProduced(to: self) { this, s in
                    this.eventProducer.input(value: s)
                }
//                .attach {
//                    if let v = selected {
//                        $0.viewState.value = v
//                    }
//                }
            
            UIView().attach($0).size(.fill, Util.pixel(1))
                .backgroundColor(Theme.dividerColor)
            
            Label(self.desc).attach($0)
                .textAlignment(.left)
                .margin(all: 4)
                .size(.fill, .wrap)
                .visibility(self.desc.count > 0 ? .visible : .gone)
        }
        .animator(Animators.default)
        .size(.fill, .wrap)
        .backgroundColor(Theme.card)
        .style(ShadowStyle())
//        .cornerRadius(4)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
