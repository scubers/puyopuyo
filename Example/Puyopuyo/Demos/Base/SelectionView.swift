//
//  SelectionView.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/12/6.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Puyopuyo

struct Selector<T> {
    var desc: String
    var value: T
}

class SelectionView<T: Equatable>: VFlow, Stateful, Eventable {
    
    private var selection = [Selector<T>]()
    
    var viewState = State<Selector<T>?>(nil)
    var eventProducer = SimpleIO<Selector<T>>()
    
    init(_ selection: [Selector<T>]) {
        self.selection = selection
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func buildBody() {
        attach { v in
            self.selection.enumerated().forEach { (arg) in
                
                let (_, x) = arg
                UIButton().attach(v)
                    .onTap(to: self, { (self, _) in
                        self.eventProducer.input(value: x)
                        self.viewState.value = x
                    })
                    .backgroundColor(self.viewState.asOutput().map({ (e) -> UIColor in
                        if let e = e, e.value == x.value {
                            return Theme.color
                        }
                        return .clear
                    }))
                    .styles([
                        TapScaleStyle()
                    ])
                    .borderWidth(0.5)
                    .borderColor(Theme.color)
                    .cornerRadius(4)
                    .textColor(UIColor.black, state: .normal)
                    .width(.wrap(add: 6))
                    .text(x.desc, state: .normal)
            }
        }
        .arrangeCount(0)
        .padding(all: 10)
        .space(5)
        .animator(Animators.default)
    }
    
}
