//
//  Size.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import UIKit

public protocol MeasureDelegate: AnyObject {
    var py_size: CGSize { get set }

    var py_center: CGPoint { get set }

    func py_enumerateChild(_ block: (Measure) -> Void)

    func py_sizeThatFits(_ size: CGSize) -> CGSize

    func py_setNeedsRelayout()
}

/// 描述一个节点相对于父节点的属性
public class Measure: MeasureDelegate, Hashable {
    public static func == (lhs: Measure, rhs: Measure) -> Bool {
        return lhs === rhs
    }

    public func hash(into _: inout Hasher) {}

    /// 虚拟目标计算节点
    var virtualDelegate = VirtualTarget()

    /// 真实计算节点
    private weak var delegate: MeasureDelegate?

    public init(target: MeasureDelegate? = nil, children: [Measure] = []) {
        self.delegate = target
        virtualDelegate.children = children
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

    public func calculate(by size: CGSize) -> CGSize {
        return MeasureCalculator.calculate(measure: self, residual: size)
    }

    public var py_size: CGSize {
        set {
            if getRealDelegate().py_size != newValue {
                getRealDelegate().py_size = newValue
            }
        }
        get {
            return getRealDelegate().py_size
        }
    }

    public var py_center: CGPoint {
        set {
            getRealDelegate().py_center = newValue
        }
        get {
            return getRealDelegate().py_center
        }
    }

    public func py_enumerateChild(_ block: (Measure) -> Void) {
        getRealDelegate().py_enumerateChild(block)
    }

    public func py_sizeThatFits(_ size: CGSize) -> CGSize {
        return getRealDelegate().py_sizeThatFits(size)
    }

    func getRealDelegate() -> MeasureDelegate {
        if let target = delegate {
            return target
        }
        return virtualDelegate
    }

    public func py_setNeedsRelayout() {
        getRealDelegate().py_setNeedsRelayout()
    }
}

class VirtualTarget: MeasureDelegate {
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
