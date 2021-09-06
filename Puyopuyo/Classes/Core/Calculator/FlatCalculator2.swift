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

     f_f, f_w: 必须最先计算，主轴固定尺寸优先级最高

     w_f, w_w, w_r: 下一步根据 主轴 w 的 priority 的优先级计算

     r_w, f_r, r_f, r_r: 必须最后计算，主次都依赖剩余空间, f 不依赖其他参数

 -- 第三次循环 --
 1. 计算子节点的大小

     1.1 每次循环获取剩余空间大小
     1.2 计算节点大小

 2. 修正次轴r

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
class FlatCalculator2 {
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

    // 初始化主轴固有长度为 main padding
    var totalSpace: CGFloat = 0
    // 不包含布局的padding
    var totalSubMain: CGFloat = 0

    var maxSubCross: CGFloat = 0

    /// 主轴比例子项目
    var ratioMainMeasures = [Measure]()
    /// 主轴比例分母
    var totalMainRatio: CGFloat = 0
    /// 需要计算的子节点
    var calculateChildren = [Measure]()

    private lazy var crossRatioChildren = [Measure]()

    /// 是否可用format，主轴为包裹，或者存在主轴比例的子节点时，则不能使用
    var formattable: Bool = true

    /// 计算本身布局属性，可能返回的size 为 .fixed, .ratio, 不可能返回wrap
    func calculate() -> Size {
        // 第一次循环
        regulator.enumerateChild { _, m in
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
                totalSubMain += subCalSize.main.fixedValue
            }

            totalSubMain += subCalMargin.mainFixed

            // 记录次轴最大值: 固定次轴尺寸 + 次轴margin
            if subCalSize.cross.isFixed {
                maxSubCross = max(maxSubCross, subCalSize.cross.fixedValue + subCalMargin.crossFixed)
            }

            if subCalSize.cross.isRatio {
                crossRatioChildren.append(m)
            }

            // 统计主轴比例总和
            totalMainRatio += subCalSize.main.ratio
            // 添加计算子节点
            calculateChildren.append(m)
        }

        // 累加space到totalSpace
        totalSpace += (CGFloat(calculateChildren.count - 1) * regulator.space)

        // 根据优先级计算
        getSortedChildren(calculateChildren).forEach { calculateChild($0) }

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
        var main = regulator.size.getMain(parent: parent.direction)
        if main.isWrap {
            if parent.direction == regulator.direction {
                main = .fix(main.getWrapSize(by: lastEnd + regCalPadding.end))
            } else {
                main = .fix(main.getWrapSize(by: maxSubCross + regCalPadding.crossFixed))
            }
        }
        var cross = regulator.size.getCross(parent: parent.direction)
        if cross.isWrap {
            if parent.direction == regulator.direction {
                cross = .fix(cross.getWrapSize(by: maxSubCross + regCalPadding.crossFixed))
            } else {
                cross = .fix(cross.getWrapSize(by: lastEnd + regCalPadding.end))
            }
        }

        return CalSize(main: main, cross: cross, direction: parent.direction).getSize()
    }

    private func calculateChild(_ measure: Measure) {
        let subRemain = getCurrentChildRemainCalFixedSize(measure)
        calculateChild(measure, subRemain: subRemain)
    }

    private func getCurrentChildRemainCalFixedSize(_ measure: Measure) -> CalFixedSize {
        let calSubSize = measure.size.getCalSize(by: regDirection)
        let subCalMargin = measure.margin.getCalEdges(by: regDirection)

        // 总剩余空间 - 主轴固定长度 - 总间隙 + 当前节点主轴margin
        var mainRemain: CGFloat = regChildrenRemainCalSize.main - totalSubMain - totalSpace + subCalMargin.mainFixed

        if calSubSize.main.isFixed {
            // 子主轴固定时，剩余空间需要减去当前固定尺寸
            mainRemain += calSubSize.main.fixedValue
        } else if calSubSize.main.isWrap {
            // 包裹时就是当前剩余空间
        } else if calSubSize.main.isRatio {
            // 子主轴比重，需要根据当前剩余空间 & 比重进行计算
            mainRemain = mainRemain * (calSubSize.main.ratio / totalMainRatio)
        }

        var crossRemain: CGFloat = regChildrenRemainCalSize.cross
        // 次轴上父子依赖的时候，剩余空间取当前已计算的最大次轴
        if calSubSize.cross.isRatio, regCalSize.cross.isWrap {
            crossRemain = maxSubCross
        }

        return CalFixedSize(main: mainRemain, cross: crossRemain, direction: regDirection)
    }

    private func calculateChild(_ measure: Measure, subRemain: CalFixedSize) {
        let subCalSize = measure.size.getCalSize(by: regDirection)

        let subEstimateSize = _getEstimateSize(measure: measure, remain: subRemain.getSize())
        if subEstimateSize.maybeWrap() {
            fatalError("计算后的尺寸不能是包裹")
        }
        Calculator.applyMeasure(measure, size: subEstimateSize, currentRemain: subRemain.getSize(), ratio: nil)
        let subFixedSize = CalFixedSize(cgSize: measure.py_size, direction: regDirection)
        let subCalMargin = measure.margin.getCalEdges(by: regDirection)

        if subCalSize.main.isWrap {
            totalSubMain += subFixedSize.main
        }
        if subCalSize.cross.isWrap {
            maxSubCross = max(maxSubCross, subFixedSize.cross + subCalMargin.crossFixed)
        }

        if regulator.calculateChildrenImmediately {
            _ = measure.calculate(byParent: regulator, remain: subRemain.getSize())
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
            case .between where measures.count > 1 && calculateIndex != 0:
                delta = (regChildrenRemainCalSize.main - totalSubMain) / CGFloat(measures.count - 1) - regulator.space
            case .round:
                delta = (regChildrenRemainCalSize.main - totalSubMain) / CGFloat(measures.count + 1) - (calculateIndex == 0 ? 0 : regulator.space)
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
        return measure.calculate(byParent: regulator, remain: remain)
    }
}

extension CalSize {
    struct Priority: Comparable {
        static func < (lhs: CalSize.Priority, rhs: CalSize.Priority) -> Bool {
            if lhs.level == rhs.level {
                return lhs.priority > rhs.priority
            }
            return lhs.level < rhs.level
        }

        var level: Int
        var priority: Double

        static func level1() -> Priority {
            .init(level: 0, priority: 0)
        }

        static func level2(priority: Double) -> Priority {
            .init(level: 10, priority: priority)
        }

        static func level3() -> Priority {
            .init(level: 20, priority: 0)
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
            return .level2(priority: main.priority)
        }
        // level 3: r_w, f_r, r_f, r_r
        return .level3()
    }
}
