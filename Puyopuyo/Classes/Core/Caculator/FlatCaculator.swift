//
//  LineCaculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

/**
 =============== 线性布局计算逻辑 ===============
 -- 预处理 --
 1. 若布局非包裹cross，则最大cross由剩余空间cross确定(maxCross)

 -- 第一次循环 --
 1. 筛选activate = true 的子节点
 2. 校验是否可以format
 3. 判断主轴冲突(布局主轴为包裹，则子节点主轴不能有ratio)
 4. 累加主轴比例总和 (totalMainRatio)
 5. 累加固定尺寸(F_R, R_F)
 6. 保存需要计算的子节点

 -- 校验冲突 --
 1. 若布局可能包裹，则 w_r, r_w 不能同时存在

 -- 第二次循环 --
 1. 根据子节点的size的计算优先级进行排序

 -- 第三次循环 --
 1. 计算子节点的大小

 -- 第四次循环 --
 1. 计算根据format(.between, .leading, .round)计算center值

 -- 可能存在的第五次循环 --
 1. 若format值 == .trailing || .center,则需要第五次循环计算format的偏移量

 =============== 线性布局子节点计算逻辑说明 ===============
 1. 子节点Size(width,height) 会根据direction来转换为 CalSize(main,cross)来进行计算
    main为direction主轴方向，cross为垂直于main的次轴方向。
 2. Size会有三种描述 (fix, ratio, wrap), 对应宽高的组合，则有 9 种搭配方式: (main|cross)
    (f_f),(w_w, w_f, f_w),(w_r, r_w),(r_f, f_r),(r_r)
    对应的计算顺序参考枚举 @see CalPriority，枚举值越小，优先计算
    具体计算逻辑参考 @see FlatCaculator.regulateChild(_:)
 3. 包裹尺寸计算时候会根据优先级进行排序，但是若布局为包裹，子节点有个特殊包裹(w_r)不会.wrap(priority:)影响

 */
class FlatCaculator {
    let regulator: FlatRegulator
    let parent: Measure
    let remain: CGSize
    init(_ regulator: FlatRegulator, parent: Measure, remain: CGSize) {
        self.regulator = regulator
        self.parent = parent
        self.remain = remain
    }

    /// 当前剩余尺寸，需要根据属性进行计算，由于当前计算即所有剩余尺寸，所以ratio为比例相同
    lazy var regChildrenRemainCalSize: CalFixedSize = {
        let size = Caculator.getChildRemainSize(self.regulator.size,
                                                superRemain: self.remain,
                                                margin: self.regulator.margin,
                                                padding: self.regulator.padding,
                                                ratio: nil)
        return CalFixedSize(cgSize: size, direction: self.regulator.direction)
    }()

    var regCalMargin: CalEdges { CalEdges(insets: regulator.margin, direction: regulator.direction) }
    var regCalPadding: CalEdges { CalEdges(insets: regulator.padding, direction: regulator.direction) }
    var regCalSize: CalSize { CalSize(size: regulator.size, direction: regulator.direction) }

    var regDirection: Direction { regulator.direction }

    // 初始化主轴固有长度为 main padding
    var totalSpace: CGFloat = 0
    // 不包含布局的padding
    var totalSubMain: CGFloat = 0

    var maxCross: CGFloat = 0

    /// 主轴比例子项目
    var ratioMainMeasures = [Measure]()
    /// 主轴比例分母
    var totalMainRatio: CGFloat = 0
    /// 需要计算的子节点
    var caculateChildren = [Measure]()

    /// 是否可用format，主轴为包裹，或者存在主轴比例的子节点时，则不能使用
    var formattable: Bool = true

    /// 计算本身布局属性，可能返回的size 为 .fixed, .ratio, 不可能返回wrap
    func caculate() -> Size {
        var wrCount = 0
        var rwCount = 0

        // 处理非包裹cross时的masCross
        if regCalSize.cross.isRatio {
            maxCross = regChildrenRemainCalSize.cross
        } else if regCalSize.cross.isFixed {
            maxCross = regCalSize.cross.fixedValue - regCalPadding.crossFixed
        }

        var unRegulatable = false
        // 第一次循环
        regulator.enumerateChild { _, m in
            guard m.activated else { return }
            let subCalSize = m.size.getCalSize(by: regDirection)
            let subCalMargin = m.margin.getCalEdges(by: regDirection)

            // 校验是否可format
            if (subCalSize.main.isRatio && formattable || regCalSize.main.isWrap) && regulator.format != .leading {
                _setNotFormattable()
            }

            // 判断主轴包裹冲突
            if regCalSize.main.isWrap && subCalSize.main.isRatio {
                Caculator.constraintConflict(crash: false, "parent wrap cannot contain main ratio children!!!!!")
                unRegulatable = true
                
            }

            // 判断W_R优先级冲突
            if regulator.size.maybeWrap(), subCalSize.main.isWrap, subCalSize.main.priority > 0 {
                // 警告包裹布局内，(W_R) 节点的wrap priority 不生效，先不打印警告
//                Caculator.constraintConflict(crash: false, "In wrap regulator, child node which size is (W_R)'s wrap priority will not work!!!!")
            }

            // 准备冲突数据
            switch subCalSize.flatCaculatePriority() {
            case .W_R: wrCount += 1
            case .R_W: rwCount += 1
            case .F_R: totalSubMain += subCalSize.main.fixedValue + subCalMargin.mainFixed
            case .R_F: if regCalSize.cross.isWrap { maxCross = max(maxCross, subCalSize.cross.fixedValue + subCalMargin.crossFixed) }
            default: break
            }
            // 统计主轴比例总和
            totalMainRatio += subCalSize.main.ratio
            // 添加计算子节点
            caculateChildren.append(m)
        }
        
        if unRegulatable {
            Caculator.constraintConflict(crash: false, "Current regulator[\(self.regulator)] cannot regulated!!!!")
            return Size()
        }

        // 校验冲突，若布局可能包裹，则不能存在 wrrw
        if regulator.size.maybeWrap(), wrCount > 0, rwCount > 0 {
            Caculator.constraintConflict(crash: false, "[\(regulator.getRealTarget())] children's size contains [W_R, R_W], this should cause some unexceptable result !!!!")
        }

        // 2.准备信息
        // 2.2 累加space到totalSpace
        totalSpace += max(0, CGFloat(caculateChildren.count - 1) * regulator.space)

        // 根据优先级计算
        sortedChildren(caculateChildren).forEach { regulateChild($0) }

        // 4、第三次循环，计算子节点center，若format == .trailing, 则可能出现第四次循环
        let lastEnd = caculateCenter(measures: caculateChildren)

        // 计算自身大小
        var main = regulator.size.getMain(parent: parent.direction)
        if main.isWrap {
            if parent.direction == regulator.direction {
                main = .fix(main.getWrapSize(by: lastEnd + regCalPadding.end))
            } else {
                main = .fix(main.getWrapSize(by: maxCross + regCalPadding.crossFixed))
            }
        }
        var cross = regulator.size.getCross(parent: parent.direction)
        if cross.isWrap {
            if parent.direction == regulator.direction {
                cross = .fix(cross.getWrapSize(by: maxCross + regCalPadding.crossFixed))
            } else {
                cross = .fix(cross.getWrapSize(by: lastEnd + regCalPadding.end))
            }
        }

        return CalSize(main: main, cross: cross, direction: parent.direction).getSize()
    }

    private func regulateChild(_ measure: Measure) {
        let priority = measure.size.getCalSize(by: regDirection).flatCaculatePriority()
        switch priority {
        case .F_F, .wrapFixMix:
            let subRemain = getCurrentRemainSizeForNormalChildren().getSize()
            regulateChild(measure, priorities: [priority], remain: subRemain, appendCross: regCalSize.cross.isWrap, appendMain: true)

        case .W_R:
            var subRemain = getCurrentRemainSizeForNormalChildren()
            subRemain.cross = maxCross
            regulateChild(measure, priorities: [priority], remain: subRemain.getSize(), appendCross: false, appendMain: true)

        case .R_W:
            let subRemain = getCurrentRemainSizeForRatioChildren(measure: measure)
            regulateChild(measure, priorities: [priority], remain: subRemain.getSize(), appendCross: regCalSize.cross.isWrap, appendMain: false)

        case .R_F:
            let subRemain = getCurrentRemainSizeForRatioChildren(measure: measure)
            regulateChild(measure, priorities: [priority], remain: subRemain.getSize(), appendCross: false, appendMain: false)

        case .F_R:
            let subRemain = getCurrentRemainSizeForNormalChildren()
            regulateChild(measure, priorities: [priority], remain: subRemain.getSize(), appendCross: false, appendMain: false)

        case .R_R:
            let subRemain = getCurrentRemainSizeForRatioChildren(measure: measure)
            regulateChild(measure, priorities: [priority], remain: subRemain.getSize(), appendCross: false, appendMain: false)

        case .unknown: break
        }
    }

    private func regulateChild(_ measure: Measure, priorities: [CalSize.CalPriority], remain: CGSize, appendCross: Bool, appendMain: Bool) {
        let subCalSize = measure.size.getCalSize(by: regDirection)
        let priority = subCalSize.flatCaculatePriority()
        guard priorities.contains(priority) else { return }

        let subRemain = remain.getCalFixedSize(by: regDirection)
        let subEstimateSize = _getEstimateSize(measure: measure, remain: subRemain.getSize())
        if subEstimateSize.maybeWrap() {
            fatalError("计算后的尺寸不能是包裹")
        }
        Caculator.applyMeasure(measure, size: subEstimateSize, currentRemain: subRemain.getSize(), ratio: nil)
        let subFixedSize = CalFixedSize(cgSize: measure.py_size, direction: regDirection)
        let subCalMargin = measure.margin.getCalEdges(by: regDirection)
        if appendCross {
            maxCross = max(subFixedSize.cross + subCalMargin.crossFixed, maxCross)
        }
        if appendMain {
            totalSubMain += (subFixedSize.main + subCalMargin.mainFixed)
        }
        if regulator.caculateChildrenImmediately {
            _ = measure.caculate(byParent: regulator, remain: subRemain.getSize())
        }
    }

    private lazy var placeholders = [Measure]()

    private func getPlaceholder() -> Measure {
        let m = MeasureFactory.getPlaceholder()
        let calSize = CalSize(main: .fill, cross: .fix(0), direction: regulator.direction)
        m.size = calSize.getSize()
        return m
    }

    deinit {
        MeasureFactory.recyclePlaceholders(placeholders)
    }

    private func getCurrentRemainSizeForNormalChildren() -> CalFixedSize {
        let size = CalFixedSize(main: max(0, regChildrenRemainCalSize.main - totalSubMain - totalSpace),
                                cross: max(0, regChildrenRemainCalSize.cross),
                                direction: regDirection)
        return size
    }

    private func getCurrentRemainSizeForRatioChildren(measure: Measure) -> CalFixedSize {
        let calSize = measure.size.getCalSize(by: regDirection)
        let mainMax = max(0, (calSize.main.ratio / totalMainRatio) * (regChildrenRemainCalSize.main - totalSubMain - totalSpace))
        return CalFixedSize(main: mainMax, cross: max(0, regChildrenRemainCalSize.cross), direction: regDirection)
    }

    private func appendAndRegulateNormalChild(_ measure: Measure) {
        caculateChildren.append(measure)
        /// 子margin
        let subCalMargin = CalEdges(insets: measure.margin, direction: regDirection)

        let subCalSize = measure.size.getCalSize(by: regDirection)
        if subCalSize.main.isRatio {
            // 需要保存起来，最后计算
            ratioMainMeasures.append(measure)
            totalMainRatio += subCalSize.main.ratio
        } else {
            // 计算size的具体值
            let subRemain = getCurrentRemainSizeForNormalChildren().getSize()
            let subEstimateSize = _getEstimateSize(measure: measure, remain: subRemain)
            if subEstimateSize.maybeWrap() {
                fatalError("计算后的尺寸不能是包裹")
            }
            // 应用尺寸
            Caculator.applyMeasure(measure, size: subEstimateSize, currentRemain: subRemain, ratio: nil)
            // 记录最大cross
            let subFixedSize = CalFixedSize(cgSize: measure.py_size, direction: regDirection)
            maxCross = max(subFixedSize.cross + subCalMargin.crossFixed, maxCross)
            // 累计main长度
            totalSubMain += (subFixedSize.main + subCalMargin.mainFixed)

            if regulator.caculateChildrenImmediately {
                _ = measure.caculate(byParent: regulator, remain: subRemain)
            }
        }
    }

    private func regulateRatioChild(_ measure: Measure) {
        // 子节点剩余
        let subRemain = getCurrentRemainSizeForRatioChildren(measure: measure).getSize()
        // 子节点预计算尺寸（不会是wrap）
        let subEstimateSize = _getEstimateSize(measure: measure, remain: subRemain)
        if subEstimateSize.maybeWrap() {
            fatalError("计算后的尺寸不能是包裹")
        }
        // 子节点外边距
        let subCalMargin = CalEdges(insets: measure.margin, direction: regDirection)
        // 应用子节点具体大小
        Caculator.applyMeasure(measure, size: subEstimateSize, currentRemain: subRemain, ratio: nil)
        // 记录最大cross
        let subFixedSize = CalFixedSize(cgSize: measure.py_size, direction: regDirection)
        maxCross = max(subFixedSize.cross + subCalMargin.crossFixed, maxCross)

        if regulator.caculateChildrenImmediately {
            _ = measure.caculate(byParent: regulator, remain: subRemain)
        }
    }

    /// 这里为measures的大小都计算好，需要计算每个节点的center
    ///
    /// - Parameters:
    ///   - measures: 已经计算好大小的节点
    /// - Returns: 返回最后节点的end(包括最后一个节点的margin.end)
    private func caculateCenter(measures: [Measure]) -> CGFloat {
        var lastEnd: CGFloat = regCalPadding.start
        let reversed = regulator.reverse
        for caculateIndex in 0 ..< measures.count {
            // 获取计算对象，根据是否反转获取
            let m = reversed ? measures[measures.count - caculateIndex - 1] : measures[caculateIndex]
            // 计算cross偏移
            let cross = _caculateCrossOffset(measure: m)
            // 计算main偏移
            // 1. 计算之前，需要根据format计算补充间距
            var delta: CGFloat = 0
            switch regulator.format {
            // between 和 main 会忽略space的作用
            case .between where measures.count > 1 && caculateIndex != 0:
                delta = (regChildrenRemainCalSize.main - totalSubMain) / CGFloat(measures.count - 1) - regulator.space
            case .round:
                delta = (regChildrenRemainCalSize.main - totalSubMain) / CGFloat(measures.count + 1) - (caculateIndex == 0 ? 0 : regulator.space)
            default: break
            }
            let (main, end) = _caculateMainOffset(measure: m, idx: caculateIndex, lastEnd: lastEnd + delta)
            // 复制最后lastEnd
            lastEnd = end
            // 赋值center
            m.py_center = CalCenter(main: main, cross: cross, direction: regDirection).getPoint()
        }

        // 整体偏移
        var delta: CGFloat = 0
        switch regulator.format {
        case .trailing:
            delta = regChildrenRemainCalSize.main - regCalPadding.end - lastEnd + regCalPadding.mainFixed
        case .center:
            delta = regChildrenRemainCalSize.main / 2 - (totalSubMain + totalSpace) / 2
        default: break
        }

        if delta != 0 {
            // 如果格式化为靠后，则需要最后重排一遍
            // 计算最后一个需要移动的距离
            measures.forEach { m in
                var calCenter = m.py_center.getCalCenter(by: regulator.direction)
                calCenter.main += delta
                m.py_center = calCenter.getPoint()
            }
        }

        return lastEnd
    }

    private func sortedChildren(_ children: [Measure]) -> [Measure] {
        let sorted = children.sorted {
            let size0 = $0.size.getCalSize(by: regDirection)
            let size1 = $1.size.getCalSize(by: regDirection)

            let p0 = size0.flatCaculatePriority()
            let p1 = size1.flatCaculatePriority()

            if regulator.size.bothNotWrap(),
                p0.isWrapPrioritable(),
                p1.isWrapPrioritable() {
                // 布局为非包裹的优先级
                return size0.main.priority > size1.main.priority
            } else if
                regulator.size.maybeWrap(),
                p0.isWrapPrioritable(),
                p1.isWrapPrioritable(),
                p0 != .W_R,
                p1 != .W_R {
                // 布局为包裹的优先级
                return size0.main.priority > size1.main.priority
            }
            // 否则则使用默认优先级
            return p0.rawValue < p1.rawValue
        }
        return sorted
    }

    private func _caculateCrossOffset(measure: Measure) -> CGFloat {
        let parentSize = Caculator.getSize(regulator, currentRemain: remain, wrapContentSize: CalFixedSize(main: 0, cross: maxCross, direction: regDirection).getSize())
        return Caculator.caculateCrossAlignmentOffset(measure, direction: regDirection, justifyContent: regulator.justifyContent, parentPadding: regulator.padding, parentSize: parentSize)
    }

    private func _caculateMainOffset(measure: Measure, idx: Int, lastEnd: CGFloat) -> (CGFloat, CGFloat) {
        let calMargin = CalEdges(insets: measure.margin, direction: regulator.direction)
        let calFixedSize = CalFixedSize(cgSize: measure.py_size, direction: regulator.direction)
        let space = (idx == 0) ? 0 : regulator.space
        // main = end + 间距 + 自身顶部margin + 自身主轴一半
        let main = lastEnd + space + calMargin.start + calFixedSize.main / 2
        return (main, main + calFixedSize.main / 2 + calMargin.end)
    }

    private func _getEstimateSize(measure: Measure, remain: CGSize) -> Size {
        // 非包裹大小，可直接返回计算
        if measure.size.bothNotWrap() {
            return measure.size
        }
        return measure.caculate(byParent: regulator, remain: remain)
    }

    private func _setNotFormattable() {
//        Caculator.constraintConflict(crash: false, "Regulator[\(regulator)] Format.\(regulator.format) reset to .leading")
        formattable = false
        regulator.format = .leading
    }
}

extension CalSize {
    // 值越低越优先计算
    enum CalPriority: Int {
        case F_F = 10

        case wrapFixMix = 20
        case W_R = 30
        case R_W = 40

        case R_F = 50
        case F_R = 60

        case R_R = 70

        case unknown = 9999

        func isWrapPrioritable() -> Bool {
            return rawValue >= CalPriority.wrapFixMix.rawValue && rawValue <= CalPriority.W_R.rawValue
        }
    }

    func flatCaculatePriority() -> CalPriority {
        // main + cross
        // fix + fix
        if main.isFixed && cross.isFixed { return .F_F }
        // wrap + wrap || wrap + fix || fix + wrap
        if (main.isWrap && cross.isWrap)
            || (main.isWrap && cross.isFixed)
            || (main.isFixed && cross.isWrap) { return .wrapFixMix }

        // wrap + ratio
        if main.isWrap, cross.isRatio { return .W_R }
        // ratio + wrap
        if main.isRatio, cross.isWrap { return .R_W }

        // ratio + fix
        if main.isRatio, cross.isFixed { return .R_F }
        // fix + ratio
        if main.isFixed, cross.isRatio { return .F_R }
        // ratio + ratio
        if main.isRatio, cross.isRatio { return .R_R }

        return .unknown
    }
}
