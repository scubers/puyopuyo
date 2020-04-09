//
//  TGVC.swift
//  Puyopuyo_Example
//
//  Created by 王俊仁 on 2020/4/8.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import TangramKit


class TGVC: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isTranslucent = false

//        wrapFill()
        wrapOver()

        Util.randomViewColor(view: view)
    }
    
    func wrapOver() {
        let root = TGLinearLayout(.vert)
        root.tg_size(width: .fill, height: .fill)
        view.addSubview(root)

        let layout = TGLinearLayout(.vert)
        layout.tg_size(width: 100, height: 100)
        layout.tg_space = 10
        root.addSubview(layout)
        
        let v1 = Label.demo("lsdkflskdjflkjsd")
        v1.tg_size(width: .wrap, height: .wrap)
        v1.tg_width.equal(layout)
        layout.addSubview(v1)
        
//        let v2 = UIView()
//        v2.tg_size(width: .fill, height: 30)
//        layout.addSubview(v2)
    }
    
    func wrapFill() {
        let root = TGLinearLayout(.vert)
        root.tg_size(width: .fill, height: .fill)
        view.addSubview(root)

        let layout = TGLinearLayout(.vert)
        layout.tg_size(width: .wrap, height: .fill)
        layout.tg_space = 10
        root.addSubview(layout)
        
        let v1 = UIView()
        v1.tg_size(width: .fill, height: 50)
        layout.addSubview(v1)
        
        let v2 = UIView()
        v2.tg_size(width: .fill, height: 30)
        layout.addSubview(v2)

    }
}
