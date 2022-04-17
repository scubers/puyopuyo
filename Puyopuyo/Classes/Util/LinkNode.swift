//
//  LinkNode.swift
//  Puyopuyo
//
//  Created by J on 2022/3/30.
//

import Foundation

class LinkList<T> {
    private(set) var count: Int = 0

    var isEmpty: Bool { count == 0 }

    private var headNode = Node<T>()
    private var lastNode: Node<T>?

    private var appendingNode: Node<T> {
        guard let lastNode = lastNode else {
            return headNode
        }
        return lastNode
    }

    private var enumeratingCount = 0

    var first: T? { headNode.next?.value }
    var last: T? { lastNode?.value }

    func append(_ value: T) {
        let node = Node(value)

        appendingNode.next = node
        node.previous = appendingNode
        lastNode = node

        count += 1
    }

    func forEach(_ block: (T) -> Void) {
        _forEachNode { block($0.value) }
    }

    private func _forEachNode(_ block: (Node<T>) -> Void) {
        doEnumerate {
            var current = headNode.next
            while current != nil {
                block(current!)
                current = current?.next
            }
        }
    }

    private func _reverseForEachNode(_ block: (Node<T>) -> Void) {
        doEnumerate {
            var current = lastNode
            while current != nil, current !== headNode {
                block(current!)
                current = current?.previous
            }
        }
    }

    private func doEnumerate(_ block: () -> Void) {
        enumeratingCount += 1
        block()
        enumeratingCount -= 1
    }

    func reverseForEach(_ block: (T) -> Void) {
        _reverseForEachNode { block($0.value) }
    }

    func removeAll(where: (T) -> Bool = { _ in true }) {
        assert(enumeratingCount == 0)
        var pre: Node<T>?
        _forEachNode { node in
            if `where`(node.value) {
                node.previous?.next = node.next
                node.next?.previous = node.previous
                count -= 1
            } else {
                pre = node
            }
        }

        if pre !== lastNode {
            lastNode = pre
        }
    }

    func toArray() -> [T] {
        var list = [T]()
        list.reserveCapacity(count)
        forEach { list.append($0) }
        return list
    }

    private class Node<T> {
        init(_ value: T) {
            self.value = value
        }

        fileprivate init() {}

        var value: T!
        var next: Node<T>?

        weak var previous: Node<T>?
    }
}
