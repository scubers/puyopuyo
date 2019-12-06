//
//  SelectionView.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/12/6.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Puyopuyo

class SelectionView<T: Equatable>: VFlow, StatefulView, EventableView {
    
    private var selection = [T]()
    
    var viewState = State<T?>(nil)
    var eventProducer = SimpleIO<T>()
    
    init(_ selection: [T]) {
        self.selection = selection
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func buildBody() {
        regulator.arrange = 0
        attach { v in
            self.selection.enumerated().forEach { (idx, x) in
                UIButton().attach(v)
                    .onTap(to: self, { (self, _) in
                        self.eventProducer.input(value: x)
                        self.viewState.value = x
                    })
                    .backgroundColor(self.viewState.asOutput().map({ (e) -> UIColor in
                        if let e = e, e == x {
                            return .purple
                        }
                        return .gray
                    }))
                    .titleColor(UIColor.black, state: .normal)
                    .title("\(x)", state: .normal)
            }
        }
        .backgroundColor(UIColor.brown)
        .padding(all: 10)
        .space(5)
        .animator(Animators.default)
    }
    
    
}
