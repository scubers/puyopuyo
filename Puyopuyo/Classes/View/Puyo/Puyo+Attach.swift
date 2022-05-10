//
//  Puyo+Attach.swift
//  Puyopuyo
//
//  Created by J on 2022/4/30.
//

import Foundation

// MARK: - ViewDisplayable attaching

public extension ViewDisplayable {
    @discardableResult
    func attach(_ parent: ViewDisplayable, _ block: (Self) -> Void = { _ in }) -> Puyo<Self> {
        parent.dislplayView.addSubview(dislplayView)
        block(self)
        return Puyo(self)
    }
}

// MARK: - BoxLayoutNode attaching

public extension BoxLayoutNode {
    @discardableResult
    func attach(_ parent: BoxLayoutContainer? = nil, _ block: (Self) -> Void = { _ in }) -> Puyo<Self> {
        if layoutNodeType.isVirtual {
            assert(parent != nil, "Virtual group cannnot be the root!!!")
        }
        parent?.addLayoutNode(self)
        block(self)
        return Puyo(self)
    }
}
