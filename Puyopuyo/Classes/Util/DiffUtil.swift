//
//  DiffUtil.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/24.
//

import UIKit

public class Diff<T>: CustomStringConvertible {
    public struct Change<T>: CustomStringConvertible {
        public var from = -1
        public var to = -1
        public var value: T
        public var description: String {
            return "<value:\(value) | from:\(from) | to:\(to)>"
        }
    }

    class Record {
        var indexes = [Int]()
    }

    public var src: [T]
    public var dest: [T]
    private var identifier: (T) -> String

    public private(set) var insert = [Change<T>]()
    public private(set) var delete = [Change<T>]()
    public private(set) var move = [Change<T>]()
    public private(set) var stay = [Change<T>]()

    public init(src: [T], dest: [T], identifier: @escaping (T) -> String = { "\($0)" }) {
        self.src = src
        self.dest = dest
        self.identifier = identifier
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
                self.insert.append(Change(from: -1, to: idx, value: value))
            } else if index != idx {
                self.move.append(Change(from: index, to: idx, value: value))
            } else if index == idx {
                self.stay.append(Change(from: index, to: idx, value: value))
            }
        }

        src.enumerated().forEach { idx, value in
            if !(getRecord(value).indexes.removeLast() < 0) {
                self.delete.append(Change(from: idx, to: -1, value: value))
            }
        }
    }

    private var map = [String: Record]()
    private func getRecord(_ value: T) -> Record {
        if let r = map[identifier(value)] {
            return r
        }
        let r = Record()
        map[identifier(value)] = r
        return r
    }

    public func isDifferent() -> Bool {
        return !insert.isEmpty || !move.isEmpty || !delete.isEmpty
    }

    public var description: String {
        return """
        [diff] src: \(src), dest: \(dest)
        [insert] \(insert)
        [delete] \(delete)
        [move] \(move)
        """
    }
}

public extension Unmanaged where Instance: AnyObject {
    static func getIdentifier(_ object: Instance, config: (Instance) -> String = { _ in "" }) -> String {
        let addr = Unmanaged.passUnretained(object).toOpaque().debugDescription
        return "\(addr)_\(config(object))"
    }
}
