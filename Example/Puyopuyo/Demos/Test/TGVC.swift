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
//        wrapFillConflict()

        Util.randomViewColor(view: view)
    }
    
    func wrapFillConflict() {
        let root = TGLinearLayout(.vert)
        root.tg_size(width: .wrap, height: .wrap)
        view.addSubview(root)

        let layout = TGLinearLayout(.vert)
        layout.tg_size(width: .wrap, height: .wrap)
        layout.tg_space = 10
        root.addSubview(layout)
        
        let v1 = Label.demo("12345343434")
        v1.tg_size(width: .wrap, height: .fill)
        v1.tg_width.equal(layout)
        layout.addSubview(v1)
        
        let v2 = Label.demo("lsdkflskdjflkjsd")
        v2.tg_size(width: .fill, height: .wrap)
        v2.tg_width.equal(layout)
        layout.addSubview(v2)
    }
    
    func wrapOver() {
        let root = TGLinearLayout(.vert)
        root.tg_size(width: .fill, height: .fill)
        view.addSubview(root)

        let layout = TGLinearLayout(.vert)
        layout.tg_size(width: .wrap, height: .wrap)
        layout.tg_space = 10
        layout.tg_useFrame = true
        root.addSubview(layout)
        
        let v1 = Label.demo("lsdkflskdjflkjsd")
        v1.tg_size(width: .wrap, height: .wrap)
//        v1.tg_width.equal(layout)
        layout.addSubview(v1)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            layout.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        }
        
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
