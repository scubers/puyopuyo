//
//  LinkNode.swift
//  Puyopuyo
//
//  Created by J on 2022/3/30.
//

import Foundation

class LinkList<T> {
    private var leading: Node<T>?
    private var trailing: Node<T>?

    private(set) var count: Int = 0

    var isEmpty: Bool { count == 0 }

    var first: T? { leading?.value }
    var last: T? { trailing?.value }

    func append(_ value: T) {
        let node = Node(value)
        if let last = trailing {
            last.next = node
            node.previous = last
            trailing = node
        } else {
            leading = node
            trailing = node
        }
        count += 1
    }

    func forEach(_ block: (T) -> Void) {
        var current = leading
        while current != nil {
            block(current!.value)
            current = current?.next
        }
    }

    func reverseForEach(_ block: (T) -> Void) {
        var current = trailing
        while current != nil {
            block(current!.value)
            current = current?.previous
        }
    }

    private class Node<T> {
        init(_ value: T) {
            self.value = value
        }

        var value: T
        var next: Node<T>?

        weak var previous: Node<T>?
    }
}
