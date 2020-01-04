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

    @available(*, deprecated, message: "use between")
    public static var sides: Format {
        return .between
    }

    @available(*, deprecated, message: "use round")
    public static var avg: Format {
        return .round
    }
}

/// 描述一个布局具备控制子节点的属性
public class Regulator: Measure {
    /// 布局节点对子节点的整体偏移
    public var justifyContent: Alignment = .center

    /// 布局节点的内边距
    public var padding = UIEdgeInsets.zero

    /// 标记是否在本局过程中，立刻计算子节点
    public var caculateChildrenImmediately = false

    public func enumerateChild(_ block: (Int, Measure) -> Void) {
        py_enumerateChild(block)
    }

    public func getCalPadding() -> CalEdges {
        return CalEdges(insets: padding, direction: direction)
    }
}
