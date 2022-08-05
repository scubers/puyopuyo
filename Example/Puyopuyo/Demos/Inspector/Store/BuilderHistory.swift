//
//  BuilderHistory.swift
//  PuyoBuilder_Example
//
//  Created by J on 2022/6/5.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import Puyopuyo

class BuilderHistory<T>: ChangeNotifier {
    let maxCount: Int

    init(count: Int, first: T) {
        maxCount = count
        root = Node(value: first)
        current = root
        self.count = 1
    }

    var changeNotifier: Outputs<Void> { notifier.asOutput() }

    private let notifier = SimpleIO<Void>()

    private var root: Node<T>

    private(set) var current: Node<T>

    private var count: Int

    var canUndo: Bool { current.previous != nil }
    var canRedo: Bool { current.next != nil }

    var currentState: T { current.value }

    func push(_ next: T) {
        let node = Node(value: next)
        node.previous = current
        current.next = node
        current = node
        count += 1

        if count > maxCount {
            count -= 1
            root = root.next!
        }

        notifier.input(value: ())
    }

    func undo() {
        guard canUndo else {
            return
        }
        current = current.previous!
        notifier.input(value: ())
    }

    func redo() {
        guard canRedo else {
            return
        }
        current = current.next!
        notifier.input(value: ())
    }

    class Node<T> {
        init(value: T) {
            self.value = value
        }

        var value: T
        weak var previous: Node<T>?
        var next: Node<T>?
    }
}
