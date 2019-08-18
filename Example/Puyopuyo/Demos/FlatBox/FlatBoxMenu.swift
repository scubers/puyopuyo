//
//  FlatBoxMenu.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/8/11.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class FlatBoxMenu: MenuVC {
    override func getData() -> [(String, UIViewController.Type)] {
        return [
            ("VBox Base", VBoxVC.self),
            ("FlatFormationAligmentVC", FlatFormationAligmentVC.self),
        ]
    }
}
