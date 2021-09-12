//
//  FlatCalculator2.swift
//  Puyopuyo
//
//  Created by J on 2021/8/31.
//

import Foundation

/**

 =============== 线性布局主轴原则 =================
 1. 最优先保证 fix 的大小，允许超过剩余空间
 2. 根据 wrap 的 priority 保证 wrap 的大小，不允许超过剩余空间
 3. 最后根据剩余空间分配 ratio

 =============== 线性布局次轴原则 =================
 1. 次轴计算将每次都会判断并记录当前最大次轴，允许超过剩余空间（固定 or ratio 都可以）
 2. 次轴 ratio 取值为当前计算的最大max
 3. 完成整体布局计算后，将所有次轴ratio额外设置为当前最大次轴

 =============== 线性布局计算逻辑 =================

 -- 预处理 --
 1. 若布局非包裹cross，则最大cross由剩余空间cross确定(maxCross)

 -- 第一次循环 --
 1. 筛选计算节点
    1.1 activate = true
    1.2 当布局主轴 wrap，子节点主轴 ratio 不参与计算
 2. 校验是否可以format
 3. 累加主轴比例总和 (totalMainRatio)
 4. 累加主轴固定尺寸（表征当前布局的节点中，必然会使用的主轴尺寸：padding，margin，space，fix）
 5. 记录最大次轴固定尺寸
 6. 保存需要计算的子节点

 -- 第二次循环 --
 1. 根据子节点的size的计算优先级进行排序

     主_次

     f_f, f_w: 必须最先计算，主轴固定尺寸优先级最高

     w_f, w_w, w_r: 下一步根据 主轴 w 的 priority 以及 shrink 的优先级计算

     r_w, f_r, r_f, r_r: 必须最后计算，主次都依赖剩余空间, f 不依赖其他参数

 -- 第三次循环 --
 1. 计算子节点的大小

     1.1 每次循环获取剩余空间大小
     1.2 计算节点大小

 2. 处理主轴压缩 maybe +1 loop
 3. 修正次轴R maybe +1 loop

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
    具体计算逻辑参考 @see FlatCalculator.regulateChild(_:)
 3. 包裹尺寸计算时候会根据优先级进行排序，但是若布局为包裹，子节点有个特殊包裹(w_r)不会.wrap(priority:)影响

 */
class FlatCalculator {
    let regulator: FlatRegulator
    let remain: CGSize
    init(_ regulator: FlatRegulator, remain: CGSize) {
        self.regulator = regulator
        self.remain = remain
    }

    /// 当前剩余尺寸，需要根据属性进行计算，由于当前计算即所有剩余尺寸，所以ratio为比例相同
    lazy var regChildrenRemainCalSize: CalFixedSize = {
        let size = Calculator.getChildRemainSize(self.regulator.size,
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

    /// 不包含布局的padding
    var totalSubMain: CGFloat {
        // 间隙 + 主轴固定 + 主轴非压缩包裹 + 主轴压缩包裹 + 主轴margin
        totalSpace + totalMainFixedSize + totalMainPrioritiedWrapSize + totalMainShrinkWrapSize + totalMainMarginSize
    }

    /// 主轴比例剩余空间
    var totalRatioRemain: CGFloat {
        // 剩余 - 已占用
        regChildrenRemainCalSize.main - totalSubMain
    }

    /// 主轴非压缩包裹可使用剩余空间
    var totalPrioritedWrapRemain: CGFloat {
        // 剩余 - 总间隙 - 总固定 - 总margin
        regChildrenRemainCalSize.main - totalSpace - totalMainFixedSize - totalMainMarginSize
    }

    /// 主轴压缩包裹可使用空间
    var totalShrinkWrapRemain: CGFloat {
        totalPrioritedWrapRemain - totalMainPrioritiedWrapSize
    }

    /// 总间隙
    var totalSpace: CGFloat = 0

    /// 总主轴固定尺寸
    var totalMainFixedSize: CGFloat = 0
    /// 总主轴margin
    var totalMainMarginSize: CGFloat = 0
    /// 总主轴非包裹尺寸
    var totalMainPrioritiedWrapSize: CGFloat = 0
    /// 主轴压缩包裹尺寸
    var totalMainShrinkWrapSize: CGFloat = 0

    /// 记录计算好的最大次轴
    var maxSubCross: CGFloat = 0

    /// 主轴比例子项目
    var ratioMainMeasures = [Measure]()
    /// 主轴比例分母
    var totalMainRatio: CGFloat = 0
    /// 需要计算的子节点
    var calculateChildren = [Measure]()
    /// 主轴压缩分母
    var totalShrink: CGFloat = 0
    /// 计算主轴包裹时的总长度
    var totalWrapMainFixed: CGFloat = 0

    /// 次轴需要修正的子节点
    private lazy var crossRatioChildren = [Measure]()
    /// 主轴需要压缩的子节点
    private lazy var mainShrinkChildren = [Measure]()

    /// 是否可用format，主轴为包裹，或者存在主轴比例的子节点时，则不能使用
    var formattable: Bool = true

    /// 计算本身布局属性，可能返回的size 为 .fixed, .ratio, 不可能返回wrap
    func calculate() -> Size {
        // 第一次循环
        regulator.py_enumerateChild { m in
            // 未激活的节点不计算
            guard m.activated else { return }

            let subCalSize = m.size.getCalSize(by: regDirection)

            // 主轴: 布局包裹，节点ratio 将产生冲突，不参与计算
            if subCalSize.main.isRatio, regCalSize.main.isWrap {
                return
            }

            let subCalMargin = m.margin.getCalEdges(by: regDirection)

            // 校验是否可format: 主轴包裹, 或者存在子主轴比重，则不可以被format
            if formattable, regCalSize.main.isWrap || subCalSize.main.isRatio, regulator.format != .leading {
                formattable = false
            }

            // 累加主轴固定尺寸 & 主轴margin
            if subCalSize.main.isFixed {
                totalMainFixedSize += subCalSize.main.fixedValue
            }

            totalMainMarginSize += subCalMargin.mainFixed

            // 记录次轴最大值: 固定次轴尺寸 + 次轴margin
            if subCalSize.cross.isFixed {
                maxSubCross = max(maxSubCross, subCalSize.cross.fixedValue + subCalMargin.crossFixed)
            }

            if subCalSize.cross.isRatio {
                crossRatioChildren.append(m)
            }

            if subCalSize.main.shrink > 0 {
                mainShrinkChildren.append(m)
            }

            // 统计主轴比例总和
            totalMainRatio += subCalSize.main.ratio
            // 统计主轴压缩总和
            totalShrink += subCalSize.main.shrink
            // 添加计算子节点
            calculateChildren.append(m)
        }

        // 累加space到totalSpace
        totalSpace += (CGFloat(calculateChildren.count - 1) * regulator.space)

        // 根据优先级计算
        getSortedChildren(calculateChildren).forEach { calculateChild($0) }

        // 子节点超出剩余空间并且存在可压缩节点时，处理主轴压缩
        if totalShrink > 0, totalSubMain > regChildrenRemainCalSize.main {
            let overflowSize = totalSubMain - regChildrenRemainCalSize.main

            mainShrinkChildren.forEach {
                let calSize = $0.size.getCalSize(by: regDirection)
                if calSize.main.isWrap, calSize.main.shrink > 0 {
                    let calFixedSize = $0.py_size.getCalFixedSize(by: regDirection)

                    let calMargin = $0.margin.getCalEdges(by: regDirection)
                    // 需要压缩的主轴长度
                    let delta = overflowSize * (calSize.main.shrink / totalShrink)

                    let mainRemain = max(0, min(calFixedSize.main - delta, totalShrinkWrapRemain)) + calMargin.mainFixed

                    var remain = getCurrentChildRemainCalFixedSize($0)
                    remain.main = mainRemain

                    // 当前节点需要重新计算，所以先把累计值减去
                    totalMainShrinkWrapSize -= calFixedSize.main
                    // 重新计算
                    calculateChild($0, subRemain: remain)
                    // 重新累计
                    appendChildrenToCalculatedSize($0)
                }
            }
        }

        // 最后处理次轴比重
        if regCalSize.cross.isWrap {
            crossRatioChildren.forEach {
                let calSize = $0.size.getCalSize(by: regDirection)
                if calSize.cross.isRatio {
                    var calFixedSize = $0.py_size.getCalFixedSize(by: regDirection)
                    let calMargin = $0.margin.getCalEdges(by: regDirection)
                    calFixedSize.cross = maxSubCross - calMargin.crossFixed
                    $0.py_size = calFixedSize.getSize()
                }
            }
        }

        // 4、第三次循环，计算子节点center，若format == .trailing, 则可能出现第四次循环
        let lastEnd = calculateCenter(measures: calculateChildren)

        // 计算自身大小
        var main = regulator.size.getMain(direction: regDirection)
        if main.isWrap {
            main = .fix(main.getWrapSize(by: lastEnd + regCalPadding.end))
        }

        var cross = regulator.size.getCross(direction: regDirection)
        if cross.isWrap {
            cross = .fix(cross.getWrapSize(by: maxSubCross + regCalPadding.crossFixed))
        }
        return CalSize(main: main, cross: cross, direction: regDirection).getSize()
    }

    private func calculateChild(_ measure: Measure) {
        let subRemain = getCurrentChildRemainCalFixedSize(measure)
        calculateChild(measure, subRemain: subRemain)
        appendChildrenToCalculatedSize(measure)
    }

    /// 把计算好的节点的尺寸累计到统计值
    private func appendChildrenToCalculatedSize(_ measure: Measure) {
        // 计算后把包裹的大小进行累加
        let subFixedSize = CalFixedSize(cgSize: measure.py_size, direction: regDirection)
        let subCalMargin = measure.margin.getCalEdges(by: regDirection)
        let subCalSize = measure.size.getCalSize(by: regDirection)
        if subCalSize.main.isWrap {
            if subCalSize.main.shrink > 0 {
                totalMainShrinkWrapSize += subFixedSize.main
            } else {
                totalMainPrioritiedWrapSize += subFixedSize.main
            }
        }
        if subCalSize.cross.isWrap {
            maxSubCross = max(maxSubCross, subFixedSize.cross + subCalMargin.crossFixed)
        }
    }

    private func getCurrentChildRemainCalFixedSize(_ measure: Measure) -> CalFixedSize {
        let calSubSize = measure.size.getCalSize(by: regDirection)
        let subCalMargin = measure.margin.getCalEdges(by: regDirection)

        // 总剩余空间 - 主轴固定长度 + 当前节点主轴margin
        var mainRemain: CGFloat // = regChildrenRemainCalSize.main - totalSubMain + subCalMargin.mainFixed

        switch calSubSize.main.sizeType {
        case .fixed:
            // 子主轴固定时，剩余空间需要减去当前固定尺寸
            mainRemain = totalRatioRemain + calSubSize.main.fixedValue
        case .wrap:

            // 当允许压缩时，不限制剩余空间，优先算出总长度，下一步在进行处理压缩
            if calSubSize.main.shrink > 0 {
                mainRemain = .greatestFiniteMagnitude
            } else {
                // 包裹时就是当前剩余空间
                mainRemain = totalRatioRemain
            }
        case .ratio:
            // 子主轴比重，需要根据当前剩余空间 & 比重进行计算
            mainRemain = totalRatioRemain * (calSubSize.main.ratio / totalMainRatio)
        }

        var crossRemain: CGFloat = regChildrenRemainCalSize.cross
        // 次轴上父子依赖的时候，剩余空间取当前已计算的最大次轴
        if calSubSize.cross.isRatio, regCalSize.cross.isWrap {
            crossRemain = maxSubCross
        }

        return CalFixedSize(main: mainRemain + subCalMargin.mainFixed, cross: crossRemain, direction: regDirection)
    }

    private func calculateChild(_ measure: Measure, subRemain: CalFixedSize) {
        let subEstimateSize = _getEstimateSize(measure: measure, remain: subRemain.getSize())
        if subEstimateSize.maybeWrap() {
            fatalError("Estimate size cannot be wrap")
        }
        Calculator.applyMeasure(measure, size: subEstimateSize, currentRemain: subRemain.getSize(), ratio: nil)

        if regulator.calculateChildrenImmediately {
            _ = measure.calculate(remain: subRemain.getSize())
        }
    }

    /// 这里为measures的大小都计算好，需要计算每个节点的center
    ///
    /// - Parameters:
    ///   - measures: 已经计算好大小的节点
    /// - Returns: 返回最后节点的end(包括最后一个节点的margin.end)
    private func calculateCenter(measures: [Measure]) -> CGFloat {
        var lastEnd: CGFloat = regCalPadding.start
        let reversed = regulator.reverse
        let format = formattable ? regulator.format : .leading
        for calculateIndex in 0 ..< measures.count {
            // 获取计算对象，根据是否反转获取
            let m = reversed ? measures[measures.count - calculateIndex - 1] : measures[calculateIndex]
            // 计算cross偏移
            let cross = _calculateCrossOffset(measure: m)
            // 计算main偏移
            // 1. 计算之前，需要根据format计算补充间距
            var delta: CGFloat = 0
            switch format {
            // between 和 main 会忽略space的作用
            case .between where calculateIndex != 0:
                delta = (regChildrenRemainCalSize.main - totalSubMain + totalSpace) / CGFloat(measures.count - 1) - regulator.space
            case .round:
                delta = (regChildrenRemainCalSize.main - totalSubMain + totalSpace) / CGFloat(measures.count + 1) - (calculateIndex == 0 ? 0 : regulator.space)
            default: break
            }
            let (main, end) = _calculateMainOffset(measure: m, idx: calculateIndex, lastEnd: lastEnd + delta)
            // 复制最后lastEnd
            lastEnd = end
            // 赋值center
            m.py_center = CalCenter(main: main, cross: cross, direction: regDirection).getPoint()
        }

        // 整体偏移
        var delta: CGFloat = 0
        switch format {
        case .trailing:
            delta = regChildrenRemainCalSize.main - regCalPadding.end - lastEnd + regCalPadding.mainFixed
        case .center:
            delta = regChildrenRemainCalSize.main / 2 - totalSubMain / 2
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

    private func getSortedChildren(_ children: [Measure]) -> [Measure] {
        let list = children.sorted {
            let size0 = $0.size.getCalSize(by: regDirection)
            let size1 = $1.size.getCalSize(by: regDirection)
            return size0.getPriority() < size1.getPriority()
        }
//        printPriority(list)
        return list
    }

    private func printPriority(_ children: [Measure]) {
        print(children.map { $0.size.getCalSize(by: regDirection).getSizeType().getDesc() }.joined(separator: ","))
    }

    private func _calculateCrossOffset(measure: Measure) -> CGFloat {
        let parentSize = Calculator.getSize(regulator, currentRemain: remain, wrapContentSize: CalFixedSize(main: 0, cross: maxSubCross, direction: regDirection).getSize())
        return Calculator.calculateCrossAlignmentOffset(measure, direction: regDirection, justifyContent: regulator.justifyContent, parentPadding: regulator.padding, parentSize: parentSize)
    }

    private func _calculateMainOffset(measure: Measure, idx: Int, lastEnd: CGFloat) -> (CGFloat, CGFloat) {
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
        return measure.calculate(remain: remain)
    }
}

extension CalSize {
    struct Priority: Comparable {
        static func < (lhs: CalSize.Priority, rhs: CalSize.Priority) -> Bool {
            if lhs.level == rhs.level {
                if lhs.priority == rhs.priority {
                    return lhs.shrink < rhs.shrink
                } else {
                    return lhs.priority > rhs.priority
                }
            }
            return lhs.level < rhs.level
        }

        var level: Int
        var priority: CGFloat
        var shrink: CGFloat

        static func level1() -> Priority {
            .init(level: 0, priority: 0, shrink: 0)
        }

        static func level2(priority: CGFloat, shrink: CGFloat) -> Priority {
            .init(level: 10, priority: priority, shrink: shrink)
        }

        static func level3() -> Priority {
            .init(level: 20, priority: 0, shrink: 0)
        }
    }

    enum SizeType {
        case f_f
        case f_w

        case w_f
        case w_w
        case w_r

        case r_w
        case f_r
        case r_f
        case r_r

//        var description: String {
//            return "\(self)"
//        }
        func getDesc() -> String {
            "\(self)".split(separator: ".").last!.description
        }
    }

    func getSizeType() -> SizeType {
        if main.isFixed, cross.isFixed { return .f_f }
        if main.isFixed, cross.isWrap { return .f_w }

        if main.isWrap, cross.isFixed { return .w_f }
        if main.isWrap, cross.isWrap { return .w_w }
        if main.isWrap, cross.isRatio { return .w_r }

        if main.isRatio, cross.isWrap { return .r_w }
        if main.isFixed, cross.isRatio { return .f_r }
        if main.isRatio, cross.isFixed { return .r_f }
        if main.isRatio, cross.isRatio { return .r_r }
        return .f_f
    }

    func getPriority() -> Priority {
        // level 1: f_f, f_w
        if main.isFixed, cross.isFixed || cross.isWrap {
            return .level1()
        }
        // level 2: w_f, w_w, w_r
        if main.isWrap {
            return .level2(priority: main.priority, shrink: main.shrink)
        }
        // level 3: r_w, f_r, r_f, r_r
        return .level3()
    }
}
