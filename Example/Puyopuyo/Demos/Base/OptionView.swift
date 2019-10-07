//
//  OptionView.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/8/26.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Puyopuyo

class OptionView<T>: ZBox {

    var receiver: State<T>?
    var options: [T] = []
    private var action: () -> Void
    init(prefix: String, receiver: State<T>, options: [T], _ action: @escaping () -> Void = {}) {
        self.action = action
        super.init(frame: .zero)
        self.receiver = receiver
        self.options = options
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        addGestureRecognizer(tap)
        
        let text: SimpleOutput<String?> = receiver.asOutput().map({ "\(prefix): \($0)"})
        attach() {
            Label().attach($0)
                .text(text)
                .size(.fill, .fill)
        }
    }
    
    @objc private func tap() {
        let alert = UIAlertController(title: "options", message: nil, preferredStyle: .actionSheet)
        options.forEach { (o) in
            alert.addAction(UIAlertAction(title: "\(o)", style: .default, handler: { (_) in
                self.receiver?.value = o
                self.action()
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        let vc = Util.getViewController(from: self)
        vc?.present(alert, animated: true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

}
