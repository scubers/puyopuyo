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

    weak var vc: UIViewController?
    var receiver: State<T>?
    var options: [T] = []
    init(vc: UIViewController?, prefix: String, receiver: State<T>, options: [T]) {
        super.init(frame: .zero)
        self.vc = vc
        self.receiver = receiver
        self.options = options
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        addGestureRecognizer(tap)
        
        let text: State<String?> = receiver.map({ "\(prefix): \($0)"})
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
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        vc?.present(alert, animated: true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

}
