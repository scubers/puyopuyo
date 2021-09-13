//
//  Size.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import UIKit

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
            if oldValue != alignmentRatio {
                py_setNeedsRelayout()
            }
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

    public func calculate(by size: CGSize) -> Size {
        return MeasureCalculator.calculate(measure: self, residual: size)
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
