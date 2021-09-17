//
//  BaseLayout.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

/// 主轴上的子节点格式
public enum Format: CaseIterable, Outputing {
    public typealias OutputType = Format
    case leading
    case center
    case between
    case round
    case trailing
}

/// 描述一个布局具备控制子节点的属性
public class Regulator: Measure {
    /// 布局节点对子节点的整体偏移
    public var justifyContent: Alignment = .center {
        didSet {
            if oldValue != justifyContent {
                py_setNeedsRelayout()
            }
        }
    }

    /// 布局节点的内边距
    public var padding = UIEdgeInsets.zero {
        didSet {
            if oldValue != padding {
                py_setNeedsRelayout()
            }
        }
    }

    /// 标记是否在本局过程中，立刻计算子节点
    public var calculateChildrenImmediately = false {
        didSet {
            if oldValue != calculateChildrenImmediately {
                py_setNeedsRelayout()
            }
        }
    }

    override public var diagnosisMessage: String {
        """
        \(super.diagnosisMessage)
        - padding: [top: \(padding.top), left: \(padding.left), bottom: \(padding.bottom), right: \(padding.right)]
        - justifyContent: [\(justifyContent)]
        - calculateChildrenImmediately: [\(calculateChildrenImmediately)]
        """
    }
}
