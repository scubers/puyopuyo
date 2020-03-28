//
//  Puyo+UIViewController.swift
//  Puyopuyo
//
//  Created by 王俊仁 on 2020/3/28.
//

import Foundation

public extension Puyo where T: UIViewController {
    @discardableResult
    func addToParent(_ parent: UIViewController?) -> Self {
        parent?.addChild(view)
        return self
    }

    @discardableResult
    func removeFromParent() -> Self {
        view.removeFromParent()
        return self
    }
}
