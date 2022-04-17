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
    var emitter = SimpleIO<T>()
    var state = State<T?>(nil)
    
    var title: String
    var desc: String
    var selectors: [Selector<T>]
    init(title: String, builder: (UIView) -> Void, selectors: [Selector<T>], selected: T? = nil, desc: String = "") {
        self.title = title
        self.selectors = selectors
        self.desc = desc
        super.init(frame: .zero)
        
        attach {
            Label(self.title).attach($0)
                .size(.fill, 40)
                .textAlignment(.center)
                .backgroundColor(UIColor.tertiarySystemBackground)
            
            ZBox().attach($0) {
                builder($0)
            }
            .topBorder([.color(UIColor.separator), .thick(Util.pixel(1))])
            .bottomBorder([.color(UIColor.separator), .thick(Util.pixel(1))])
            .backgroundColor(UIColor.systemBackground)
            .width(.fill)
            
            VBox().attach($0) {
                
                let selectionVisible = !selectors.isEmpty
                let labelVisible = !desc.isEmpty
                
                SelectionView(selectors, selected: selected).attach($0)
                    .size(.fill, .wrap)
                    .visibility(selectionVisible.visibleOrGone)
                    .onEvent(emitter)
                
                UIView().attach($0).size(.fill, Util.pixel(1))
                    .backgroundColor(Theme.dividerColor)
                    .visibility((selectionVisible && labelVisible).visibleOrGone)
                
                Label(self.desc).attach($0)
                    .textAlignment(.left)
                    .margin(all: 4)
                    .size(.fill, .wrap)
                    .visibility(labelVisible.visibleOrGone)
            }
            .cornerRadius(8)
            .margin(all: 8)
            .backgroundColor(.quaternarySystemFill)
            .width(.fill)
        }
        .animator(Animators.default)
        .size(.fill, .wrap)
        .backgroundColor(Theme.card)
//        .style(ShadowStyle())
        .cornerRadius(8)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
