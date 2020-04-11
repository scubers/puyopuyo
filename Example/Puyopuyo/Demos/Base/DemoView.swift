//
//  DemoView.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/12/8.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Puyopuyo

typealias ViewBuilder = (UIView) -> UIView

class DemoView<T: Equatable>: VBox, Eventable {
    
    var eventProducer = SimpleIO<T>()
    
    var title: String
    var desc: String
    var selectors: [Selector<T>]
    init(title: String, builder: @escaping ViewBuilder, selectors: [Selector<T>], desc: String = "") {
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
            
            builder($0).attach($0)
            
            SelectionView(self.selectors).attach($0)
                .topBorder([.color(UIColor.black.withAlphaComponent(0.2)), .thick(Util.pixel(1))])
                .size(.fill, .wrap)
                .visibility(self.selectors.count > 0 ? .visible : .gone)
                .onEventProduced(to: self) { (self, s) in
                    self.eventProducer.input(value: s.value)
                }
            
            Spacer().attach($0).size(.fill, 0.5)
                .backgroundColor(UIColor.black.withAlphaComponent(0.2))
            
            Label(self.desc).attach($0)
                .textAlignment(.left)
                .margin(all: 4)
                .size(.fill, .wrap)
                .visibility(self.desc.count > 0 ? .visible : .gone)
        }
        .animator(Animators.default)
        .size(.fill, .wrap)
        .borderWidth(Util.pixel(1))
        .borderColor(UIColor.lightGray)
        .cornerRadius(4)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

}
