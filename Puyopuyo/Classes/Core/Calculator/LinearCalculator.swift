//
//  LinearCaclculator.swift
//  Puyopuyo
//
//  Created by J on 2021/8/31.
//

import Foundation

struct LinearCalculator: Calculator {
    func calculate(_ measure: Measure, layoutResidual: CGSize) -> CGSize {
        _LinearCalculator(measure as! LinearRegulator, layoutResidual: layoutResidual).calculate()
    }
}

class _LinearCalculator {
    // MARK: - Properties

    let regulator: LinearRegulator
    let layoutResidual: CGSize
    let contentResidual: CGSize
    let childrenLayoutResidual: CGSize
    init(_ regulator: LinearRegulator, layoutResidual: CGSize) {
        self.regulator = regulator
        self.layoutResidual = layoutResidual
        self.contentResidual = ResidualHelper.getContentResidual(layoutResidual: layoutResidual, margin: regulator.margin, size: regulator.size)
        self.childrenLayoutResidual = ResidualHelper.getChildrenLayoutResidual(for: regulator, regulatorLayoutResidual: layoutResidual)
    }

    // MARK: Getter

    /// 当前剩余尺寸，需要根据属性进行计算，由于当前计算即所有剩余尺寸，所以ratio为比例相同
    var regCalChildrenLayoutResidual: CalFixedSize { CalFixedSize(cgSize: childrenLayoutResidual, direction: regulator.direction) }
    var regCalMargin: CalEdges { CalEdges(insets: regulator.margin, direction: regulator.direction) }
    var regCalPadding: CalEdges { CalEdges(insets: regulator.padding, direction: regulator.direction) }
    var regCalSize: CalSize { CalSize(size: regulator.size, direction: regulator.direction) }
    var regDirection: Direction { regulator.direction }

    var totalMainChildrenContent: CGFloat {
        totalMargin + totalSpace + totalMainCalculatedSize
    }

    var totalMainRatioLayoutResidual: CGFloat {
        Swift.max(regCalChildrenLayoutResidual.main - totalMainChildrenContent, 0)
    }

    var regCalFormat: Format { formattable ? regulator.format : .leading }

    // MARK: - Calculation helper props

    /// 总间隙
    var totalSpace: CGFloat = 0
    /// 总主轴margin
    var totalMargin: CGFloat = 0

    /// 总主轴 子节点计算后占用尺寸
    var totalMainCalculatedSize: CGFloat = 0

    /// 记录计算好的最大次轴
    var maxCrossChildrenContent: CGFloat = 0

    /// 主轴比例分母
    var totalMainRatio: CGFloat = 0
    /// 主轴压缩分母
    var totalShrink: CGFloat = 0
    /// 主轴成长分母
    var totalGrow: CGFloat = 0
    /// 是否可用format，主轴为包裹，或者存在主轴比例的子节点时，则不能使用
    var formattable: Bool = true

    /// 需要计算的子节点
    var calculateChildren = [Measure]()
    /// 按照计算大小优先级排序好的子节点
    lazy var sortedChildren: [Measure] = {
        let list = calculateChildren.sorted {
            let size0 = $0.size.getCalSize(by: regDirection)
            let size1 = $1.size.getCalSize(by: regDirection)
            return LinearItemLevel.create(size0) < LinearItemLevel.create(size1)
        }
        return list
    }()

    /// 次轴需要修正的子节点
    private lazy var crossRatioChildren = [Measure]()
    /// 主轴需要压缩的子节点
    private lazy var mainShrinkChildren = [Measure]()
    /// 主轴需要成长的子节点
    private lazy var mainGrowChildren = [Measure]()

    /// 计算本身布局属性
    func calculate() -> CGSize {
        // 准备初始化计算数据
        prepareData()
        // 需要同时计算子节点
        calculateChildrenSize(estimateCross: nil)
        // 次轴冲突修正计算，需要避免此类冲突，可能造成O(n^2)的复杂度
        crossConfictCalculate()

        let finalSize = calculateRegulatorSize()

        calculateChildrenCenter(intrinsic: finalSize)

        return finalSize
    }

    private func calculateRegulatorSize() -> CGSize {
        let contentSize = CalFixedSize(main: totalMainChildrenContent, cross: maxCrossChildrenContent, direction: regDirection)
            .getSize()
            .expand(edge: regulator.padding)
        return IntrinsicSizeHelper.getIntrinsicSize(from: regulator.size, contentResidual: contentResidual, wrappedContent: contentSize)
    }

    private func calculateChildrenSize(estimateCross: CGFloat?) {
        // 清空计算值
        totalMainCalculatedSize = 0
        maxCrossChildrenContent = 0

        // 根据优先级计算
        sortedChildren.forEach {
            calculateChild($0, estimateCross: estimateCross, msg: "LinearCalculator calculating")
        }

        // 主轴压缩和成长必定互斥
        // 处理主轴压缩
        let shinkHandled = handleMainShrinkIfNeeded(estimateCross: estimateCross)
        // 处理主轴成长
        let growHandled = hendleMainGrowIfNeeded(estimateCross: estimateCross)

        if shinkHandled || growHandled {
            // 重新获取最新计算值
            totalMainCalculatedSize = 0
            maxCrossChildrenContent = 0
            calculateChildren.forEach(appendChildrenToCalculatedSize(_:))
        }
    }

    // MARK: - Private funcs

    /// 具备条件进行复算尺寸: 存在次轴父子依赖
    /// 复算可能存在无法满足期望的情况，推演最多不超过 n 次
    private func crossConfictCalculate() {
        if !crossRatioChildren.isEmpty, regCalSize.cross.isWrap {
            var estimateCross = maxCrossChildrenContent

            // 预估值复算记录
            var estimates = [CGFloat: Int]()
            // 复算次数
            var count = 0
            // 最大复算次数
            let maxLoopTestCount = 30
            // 最小误差值
            var minDelta: CGFloat?
            // 最小误差值对应的预估值
            var minDeltaEstimateCross: CGFloat?

            while true {
                // 存在重复计算 或者 超过计算次数阈值，则跳出循环
                if (estimates[estimateCross] ?? 0) > 1 || count > maxLoopTestCount {
                    print("Cross conficting, avoid parent child conflicting settings!!!!")
                    // 使用误差值最小的预估值为最终值
                    calculateChildrenSize(estimateCross: minDeltaEstimateCross!)
                    maxCrossChildrenContent = minDeltaEstimateCross!
                    break
                }

                calculateChildrenSize(estimateCross: estimateCross)
                // 计算后记录复算记录
                estimates[estimateCross] = (estimates[estimateCross] ?? 0) + 1

                let delta = maxCrossChildrenContent - estimateCross

                // 计算复算过程中的最小误差和对应预估值
                if minDelta == nil || Swift.abs(delta) < Swift.abs(minDelta!) {
                    minDelta = delta
                    minDeltaEstimateCross = estimateCross
                }

//                print(">>>> [\(count)] delta: \(delta), current: \(maxCrossChildrenContent), last: \(estimateCross)")

                if abs(delta) < 0.5 {
                    // 推算误差小于1像素
                    estimateCross = Swift.max(maxCrossChildrenContent, estimateCross)
                    calculateChildrenSize(estimateCross: estimateCross)
                    maxCrossChildrenContent = estimateCross
                    break
                } else {
                    // 推算有差距，二分法缩小差距
                    estimateCross = ((delta / 2) + estimateCross).clipDecimal(3)
                }
                count += 1
            }
//            print(">>>>> loop count: \(count), minDelta: \(minDelta!), cross: \(minDeltaEstimateCross!)")
//            print(results.filter { $1 > 1 })
        }
    }

    private func prepareData() {
        calculateChildren.reserveCapacity(regulator.children.count)
        // 第一次循环
        regulator.enumerateChildren { m in
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

            // 记录次轴最大值: 固定次轴尺寸 + 次轴margin
            if subCalSize.cross.isFixed {
                maxCrossChildrenContent = Swift.max(maxCrossChildrenContent, subCalSize.cross.fixedValue + subCalMargin.crossFixed)
            }

            // 累加主轴margin
            totalMargin += subCalMargin.mainFixed

            // 统计主轴比例总和
            totalMainRatio += subCalSize.main.ratio
            // 统计主轴压缩总和
            totalShrink += subCalSize.main.shrink
            // 统计主轴成长总和
            totalGrow += subCalSize.main.grow

            if subCalSize.cross.isRatio {
                crossRatioChildren.append(m)
            }

            if subCalSize.main.shrink > 0 {
                mainShrinkChildren.append(m)
            }

            if subCalSize.main.grow > 0 {
                mainGrowChildren.append(m)
            }

            // 添加计算子节点
            calculateChildren.append(m)
        }

        // 累加space到totalSpace
        totalSpace = CGFloat(calculateChildren.count - 1) * regulator.space
    }

    private func calculateChild(_ measure: Measure, estimateCross: CGFloat?, msg: String) {
        let subResidual = getCurrentChildLayoutResidualCalFixedSize(measure, estimateCross: estimateCross)
        calculateChild(measure, subResidual: subResidual, msg: msg)
        appendChildrenToCalculatedSize(measure)
    }

    /// 把计算好的节点的尺寸累计到统计值
    private func appendChildrenToCalculatedSize(_ measure: Measure) {
        // 计算后把包裹的大小进行累加
        let subFixedSize = CalFixedSize(cgSize: measure.calculatedSize, direction: regDirection)
        let subCalMargin = measure.margin.getCalEdges(by: regDirection)
        let subCalSize = measure.size.getCalSize(by: regDirection)
        if mainAppendableCalSize(subCalSize) {
            totalMainCalculatedSize += subFixedSize.main
        }

        if crossReplacableCalSize(subCalSize) {
            maxCrossChildrenContent = Swift.max(maxCrossChildrenContent, subFixedSize.cross + subCalMargin.crossFixed)
        }
    }

    private func mainAppendableCalSize(_ calSize: CalSize) -> Bool {
        calSize.main.sizeType != .ratio
    }

    private func crossReplacableCalSize(_ calSize: CalSize) -> Bool {
        calSize.cross.sizeType != .ratio
    }

    private func getCurrentChildLayoutResidualCalFixedSize(_ measure: Measure, estimateCross: CGFloat?) -> CalFixedSize {
        let subCalSize = measure.size.getCalSize(by: regDirection)
        let subCalMargin = measure.margin.getCalEdges(by: regDirection)

        // 总剩余空间 - 主轴固定长度 + 当前节点主轴margin
        var mainLayoutResidual: CGFloat?
        var crossLayoutResidual: CGFloat?

        func calculateMainResidual() {
            switch subCalSize.main.sizeType {
            case .fixed:
                // 子主轴固定时，剩余空间需要减去当前固定尺寸
                mainLayoutResidual = subCalSize.main.fixedValue + subCalMargin.mainFixed
            case .wrap:

                // 当允许弹性时，不限制剩余空间，优先算出总长度，下一步在进行处理压缩
                if subCalSize.main.isFlex {
                    mainLayoutResidual = .greatestFiniteMagnitude
                } else {
                    // 包裹时就是当前剩余空间
                    mainLayoutResidual = totalMainRatioLayoutResidual + subCalMargin.mainFixed
                }
            case .ratio:
                // 子主轴比重，需要根据当前剩余空间 & 比重进行计算
                mainLayoutResidual = totalMainRatioLayoutResidual * (subCalSize.main.ratio / totalMainRatio) + subCalMargin.mainFixed
            case .aspectRatio:
                mainLayoutResidual = totalMainRatioLayoutResidual + subCalMargin.mainFixed
            }
        }

        func calculateCrossResidual() {
            // 次轴上父子依赖的时候，剩余空间取当前已计算的最大次轴
            switch subCalSize.cross.sizeType {
            case .fixed:
                crossLayoutResidual = subCalSize.cross.fixedValue + subCalMargin.crossFixed
            case .wrap:
                crossLayoutResidual = regCalChildrenLayoutResidual.cross
            case .ratio:
                if let estimateCross = estimateCross {
                    crossLayoutResidual = estimateCross
                } else if !regCalSize.cross.isWrap {
                    crossLayoutResidual = (regCalChildrenLayoutResidual.cross) * subCalSize.cross.ratio
                } else {
                    crossLayoutResidual = 0 // 非复算 并且处于依赖冲突，则不参与计算，剩余空间为0
                }
            case .aspectRatio:
                crossLayoutResidual = regCalChildrenLayoutResidual.cross
            }
        }

        // 根据宽高比来规定计算顺序
        if subCalSize.cross.isAspectRatio {
            calculateMainResidual()
            calculateCrossResidual()
        } else {
            calculateCrossResidual()
            calculateMainResidual()
        }

        return CalFixedSize(main: mainLayoutResidual!, cross: crossLayoutResidual!, direction: regDirection)
    }

    private func calculateChild(_ measure: Measure, subResidual: CalFixedSize, msg: String) {
        measure.calculatedSize = IntrinsicSizeHelper.calculateIntrinsicSize(for: measure, layoutResidual: subResidual.getSize(), strategy: measure.isLayoutEntryPoint ? .estimate : .calculate, diagnosisMsg: msg)
    }

    private func hendleMainGrowIfNeeded(estimateCross: CGFloat?) -> Bool {
        // 子节点有剩余空间，并且没有ratio节点时，处理成长
        guard totalGrow > 0, totalMainRatio == 0, totalMainCalculatedSize < regCalChildrenLayoutResidual.main else {
            return false
        }
        let residualSize = totalMainRatioLayoutResidual
        mainGrowChildren.forEach { m in
            let calSize = m.size.getCalSize(by: regDirection)
            let calMargin = m.margin.getCalEdges(by: regDirection)
            let calFixedSize = m.calculatedSize.getCalFixedSize(by: regDirection)

            // 被分配的扩展长度
            let delta = residualSize * calSize.main.grow / totalGrow

            let newMainResidual = calFixedSize.main + delta + calMargin.mainFixed
            var calLayoutResidual = getCurrentChildLayoutResidualCalFixedSize(m, estimateCross: estimateCross)
            calLayoutResidual.main = newMainResidual

            // 当前节点需要重新计算，所以先把累计值减去
            totalMainCalculatedSize -= calFixedSize.main
            // 重新计算
            calculateChild(m, subResidual: calLayoutResidual, msg: "LinearCalculator grow calculating")
            // 成长计算时，最后计算值可能小于成长值，需要手动赋值
            var finalCalFixedSize = m.calculatedSize.getCalFixedSize(by: regDirection)
            finalCalFixedSize.main = calFixedSize.main + delta
            m.calculatedSize = finalCalFixedSize.getSize()
            // 重新累计
            appendChildrenToCalculatedSize(m)
        }
        return true
    }

    private func handleMainShrinkIfNeeded(estimateCross: CGFloat?) -> Bool {
        // 子节点超出剩余空间并且存在可压缩节点时，处理主轴压缩
        let overflowSize = totalMainChildrenContent - regCalChildrenLayoutResidual.main

        guard totalShrink > 0, overflowSize > 0 else {
            return false
        }
        mainShrinkChildren.forEach {
            let calSize = $0.size.getCalSize(by: regDirection)
            if calSize.main.isWrap, calSize.main.shrink > 0 {
                let calFixedSize = $0.calculatedSize.getCalFixedSize(by: regDirection)

                let calMargin = $0.margin.getCalEdges(by: regDirection)
                // 需要压缩的主轴长度
                let delta = overflowSize * (calSize.main.shrink / totalShrink)

                let newMainResidual = Swift.max(0, calFixedSize.main - delta) + calMargin.mainFixed

                var calLayoutResidual = getCurrentChildLayoutResidualCalFixedSize($0, estimateCross: estimateCross)
                calLayoutResidual.main = newMainResidual

                // 当前节点需要重新计算，所以先把累计值减去
                totalMainCalculatedSize -= calFixedSize.main
                // 重新计算
                calculateChild($0, subResidual: calLayoutResidual, msg: "LinearCalculator shrink calculating")
                // 重新累计
                appendChildrenToCalculatedSize($0)
            }
        }
        return true
    }

    /// 这里为measures的大小都计算好，需要计算每个节点的center
    ///
    /// - Parameters:
    ///   - measures: 已经计算好大小的节点
    /// - Returns: 返回最后节点的end(包括最后一个节点的margin.end)
    private func calculateChildrenCenter(intrinsic: CGSize) {
        let measures: [Measure] = calculateChildren
        let trailingDelta: CGFloat = regCalChildrenLayoutResidual.main - totalMainChildrenContent
        let centerDelta: CGFloat = trailingDelta / 2
        let betweenDelta: CGFloat = (regCalChildrenLayoutResidual.main - totalMainChildrenContent + totalSpace) / CGFloat(measures.count - 1)
        let roundDelta: CGFloat = (regCalChildrenLayoutResidual.main - totalMainChildrenContent + totalSpace) / CGFloat(measures.count + 1)
        let spaceDelta: CGFloat = regulator.space

        var standardLastEnd: CGFloat = 0
        for index in 0 ..< measures.count {
            // 获取计算对象，根据是否反转获取
            let m: Measure = regulator.reverse ? measures[measures.count - index - 1] : measures[index]
            // 计算cross偏移
            let cross: CGFloat = AlignmentHelper.getCrossAlignmentOffset(m, direction: regDirection, justifyContent: regulator.justifyContent, parentPadding: regulator.padding, parentSize: intrinsic)

            let calMargin = CalEdges(insets: m.margin, direction: regulator.direction)
            let calFixedSize = CalFixedSize(cgSize: m.calculatedSize, direction: regulator.direction)
            let standardMain: CGFloat = standardLastEnd + calMargin.leading + (calFixedSize.main / 2)
            standardLastEnd = standardMain + (calFixedSize.main / 2) + calMargin.trailing

            // 通过标准位置叠加padding和space来计算具体位置
            let calIndex = CGFloat(index)
            let itemSpaceDelta: CGFloat = spaceDelta * calIndex

            var main = standardMain + regCalPadding.leading
            switch regCalFormat {
            case .leading:
                main += itemSpaceDelta
            case .trailing:
                main += (itemSpaceDelta + trailingDelta)
            case .center:
                main += (itemSpaceDelta + centerDelta)
            case .between:
                if index != 0 {
                    main += betweenDelta * calIndex
                }
            case .round:
                main += roundDelta * (calIndex + 1)
            }

            m.calculatedCenter = CalPoint(main: main, cross: cross, direction: regDirection).getPoint()
        }
    }
}

/**
 子节点计算优先级
 主轴：能确定大小 > 比例 > 包裹大小 > 比重
 F > A > W > R

 A depend on cross
 */
struct LinearItemLevel: Comparable {
    static func < (lhs: LinearItemLevel, rhs: LinearItemLevel) -> Bool {
        if lhs.level == rhs.level {
            return lhs.priority > rhs.priority
        }
        return lhs.level < rhs.level
    }

    let level: Level

    let priority: CGFloat

    enum Level: Int, Comparable {
        static func < (lhs: LinearItemLevel.Level, rhs: LinearItemLevel.Level) -> Bool {
            lhs.rawValue < rhs.rawValue
        }

        case fixed = 0
        case aspectRatio = 1
        case wrap = 2
        case ratio = 3

        static func level(with sizeDesc: SizeDescription) -> Level {
            switch sizeDesc.sizeType {
            case .fixed: return .fixed
            case .ratio: return .ratio
            case .wrap: return .wrap
            case .aspectRatio: return .aspectRatio
            }
        }
    }

    static func create(_ calSize: CalSize) -> LinearItemLevel {
        return LinearItemLevel(level: .level(with: calSize.main), priority: calSize.main.priority)
    }
}
