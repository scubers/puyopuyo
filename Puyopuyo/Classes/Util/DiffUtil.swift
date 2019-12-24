//
//  DiffUtil.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/24.
//

import UIKit

public protocol DiffIdentiable {
    var diffIdentifier: String { get }
}

extension String: DiffIdentiable {
    public var diffIdentifier: String { self }
}

public class Diff<T: DiffIdentiable> {
    public struct Change<T> {
        public var from = 0
        public var to = 0
        public var value: T
    }

    class Record {
        var indexes = [Int]()
    }

    public var src: [T]
    public var dest: [T]

    public var insert = [Change<T>]()
    public var delete = [Change<T>]()
    public var move = [Change<T>]()

    public init(src: [T], dest: [T]) {
        self.src = src
        self.dest = dest
    }

    public func check() {
        dest.enumerated().forEach { _, value in
            self.getRecord(value).indexes.append(-1)
        }

        src.enumerated().forEach { idx, value in
            self.getRecord(value).indexes.append(idx)
        }

        dest.enumerated().forEach { idx, value in
            let r = self.getRecord(value)
            let index = r.indexes.removeLast()
            if index < 0 {
                self.insert.append(Change(from: 0, to: idx, value: value))
            } else if index != idx {
                self.move.append(Change(from: index, to: idx, value: value))
            }
        }

        src.enumerated().forEach { idx, value in
            if getRecord(value).indexes.removeLast() > 0 {
                self.delete.append(Change(from: idx, to: 0, value: value))
            }
        }
    }

    private var map = [String: Record]()
    private func getRecord(_ value: T) -> Record {
        if let r = map[value.diffIdentifier] {
            return r
        }
        let r = Record()
        map[value.diffIdentifier] = r
        return r
    }
    
    public func isDifferent() -> Bool {
        return !insert.isEmpty || !move.isEmpty || !delete.isEmpty
    }
}
