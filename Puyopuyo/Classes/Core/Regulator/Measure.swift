//
//  Size.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import UIKit

/// 布局方向，x为水平方向，y为竖直方向
public enum Direction: CaseIterable, Outputing {
    public typealias OutputType = Direction
    case x, y
}

/// 偏移枚举，可组合
public struct Alignment: OptionSet, CustomStringConvertible, Outputing {
    public typealias OutputType = Alignment
    public var description: String {
        let all = [Alignment.top, .left, .bottom, .right, .horzCenter, .vertCenter]
        let contain = all.filter { self.contains($0) }
        return
            contain.map { x -> String in
                switch x {
                case .top: return "top"
                case .left: return "left"
                case .bottom: return "bottom"
                case .right: return "right"
                case .vertCenter: return "vertCenter"
                case .horzCenter: return "horzCenter"
                default: return ""
                }
            }.joined(separator: ",")
    }

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public typealias RawValue = Int
    public let rawValue: Int

    public static let none = Alignment(rawValue: 1)
    public static let top = Alignment(rawValue: 2)
    public static let bottom = Alignment(rawValue: 4)
    public static let left = Alignment(rawValue: 8)
    public static let right = Alignment(rawValue: 16)
    public static let horzCenter = Alignment(rawValue: 32)
    public static let vertCenter = Alignment(rawValue: 64)

    public static let center = Alignment.vertCenter.union(.horzCenter)

    public static func horzAlignments() -> [Alignment] {
        return [.left, .right, .horzCenter]
    }

    public static func vertAlignments() -> [Alignment] {
        return [.top, .bottom, .vertCenter]
    }

    public func hasHorzAlignment() -> Bool {
        return
            contains(.left)
                || contains(.right)
                || contains(.horzCenter)
    }

    public func hasVertAlignment() -> Bool {
        return
            contains(.top)
                || contains(.bottom)
                || contains(.vertCenter)
    }

    public func hasMainAligment(for direction: Direction) -> Bool {
        direction == .y ? hasVertAlignment() : hasHorzAlignment()
    }

    public func hasCrossAligment(for direction: Direction) -> Bool {
        direction == .x ? hasVertAlignment() : hasHorzAlignment()
    }

    public func isCenter(for direction: Direction) -> Bool {
        if case .x = direction {
            return contains(.vertCenter)
        }
        return contains(.horzCenter)
    }

    public func isForward(for direction: Direction) -> Bool {
        if case .x = direction {
            return contains(.top)
        }
        return contains(.left)
    }

    public func isBackward(for direction: Direction) -> Bool {
        if case .x = direction {
            return contains(.bottom)
        }
        return contains(.right)
    }
}

/// 描述一个节点相对于父节点的属性
public class Measure: Measurable, MeasureTargetable, Hashable {
    public static func == (lhs: Measure, rhs: Measure) -> Bool {
        return lhs === rhs
    }

    public func hash(into _: inout Hasher) {}

    /// 虚拟目标计算节点
    var virtualTarget = VirtualTarget()

    /// 真实计算节点
    private weak var target: MeasureTargetable?

    public init(target: MeasureTargetable? = nil, children: [Measure] = []) {
        self.target = target
        virtualTarget.children = children
    }

    /// 计算节点外边距
    public var margin = UIEdgeInsets.zero {
        didSet {
            if oldValue != margin {
                py_setNeedsRelayout()
            }
        }
    }

    /// 计算节点偏移
    public var alignment: Alignment = .none {
        didSet {
            if oldValue != alignment {
                py_setNeedsRelayout()
            }
        }
    }

    public var alignmentRatio: CGSize = .init(width: 1, height: 1) {
        didSet {
            alignmentRatio.width = max(0, min(2, alignmentRatio.width))
            alignmentRatio.height = max(0, min(2, alignmentRatio.height))
            py_setNeedsRelayout()
        }
    }

    /// 计算节点大小描述
    public var size = Size(width: .wrap, height: .wrap) {
        didSet {
            if oldValue != size {
                py_setNeedsRelayout()
            }
        }
    }

    /// 只有在flowbox中生效
    public var flowEnding = false {
        didSet {
            if oldValue != flowEnding {
                py_setNeedsRelayout()
            }
        }
    }

    /// 是否激活本节点
    public var activated = true {
        didSet {
            if oldValue != activated {
                py_setNeedsRelayout()
            }
        }
    }

    public func calculate(remain size: CGSize) -> Size {
        return MeasureCalculator.calculate(measure: self, remain: size)
    }

    public var py_size: CGSize {
        set {
            getRealTarget().py_size = newValue
        }
        get {
            return getRealTarget().py_size
        }
    }

    public var py_center: CGPoint {
        set {
            getRealTarget().py_center = newValue
        }
        get {
            return getRealTarget().py_center
        }
    }

    public func py_enumerateChild(_ block: (Measure) -> Void) {
        getRealTarget().py_enumerateChild(block)
    }

    public func py_sizeThatFits(_ size: CGSize) -> CGSize {
        return getRealTarget().py_sizeThatFits(size)
    }

    func getRealTarget() -> MeasureTargetable {
        if let target = target {
            return target
        }
        return virtualTarget
    }

    public func py_setNeedsRelayout() {
        getRealTarget().py_setNeedsRelayout()
    }
}

class VirtualTarget: MeasureTargetable {
    var py_size: CGSize = .zero

    var py_center: CGPoint = .zero

    func py_enumerateChild(_ block: (Measure) -> Void) {
        children.forEach(block)
    }

    func py_sizeThatFits(_ size: CGSize) -> CGSize {
        return size
    }

    var children = [Measure]()

    func py_setNeedsRelayout() {}
}
