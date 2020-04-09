//
//  LineCaculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

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
    lazy var regRemainCalSize: CalFixedSize = {
        let size = NewCaculator.getChildRemainSize(self.regulator.size,
                                                   superRemain: self.remain,
                                                   margin: self.regulator.margin,
                                                   padding: self.regulator.padding,
                                                   ratio: nil)
        return CalFixedSize(cgSize: size, direction: self.regulator.direction)
    }()

    lazy var regCalMargin = CalEdges(insets: regulator.margin, direction: regulator.direction)
    lazy var regCalPadding = CalEdges(insets: regulator.padding, direction: regulator.direction)
    lazy var regCalSize = CalSize(size: regulator.size, direction: regulator.direction)

    lazy var regDirection = self.regulator.direction

    // 初始化主轴固有长度为 main padding
    var totalSpace: CGFloat = 0
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
//        if !(parent is Regulator) {
//            NewCaculator.applyMeasure(regulator, size: regulator.size, currentRemain: remain, ratio: .init(width: 1, height: 1))
//        }
        // 1.第一次循环，计算正常节点，忽略未激活节点，缓存主轴比例节点
        regulator.enumerateChild { _, m in
            guard m.activated else { return }
            let subSize = m.size.getCalSize(by: regulator.direction)

            if (subSize.main.isRatio && formattable || regCalSize.main.isWrap) && regulator.format != .leading {
                // 校验是否可format
                _setNotFormattable()
            }
            // 初步计算，不会计算主轴比例项目
            appendAndRegulateNormalChild(m)
        }

        // 2.准备信息
        // 2.1 准备总数，插值格式化的比例总额
        var totalCount = caculateChildren.count
        if formattable {
            switch regulator.format {
            case .center:
                totalCount += 2
                totalMainRatio = CGFloat(totalCount - caculateChildren.count)
            case .round:
                totalCount = totalCount * 2 + 1
                totalMainRatio = CGFloat(totalCount - caculateChildren.count)
            case .between:
                totalCount = totalCount * 2 - 1
                totalMainRatio = CGFloat(totalCount - caculateChildren.count)
            default: break
            }
        }

        // 2.2 累加space到totalSpace
        totalSpace += max(0, CGFloat(caculateChildren.count - 1) * regulator.space)

        // 3. 第二次循环，计算主轴比例节点
        let currentChildren = caculateChildren
        caculateChildren = []
        caculateChildren.reserveCapacity(totalCount)

        // 插入首format
        if formattable, regulator.format == .center || regulator.format == .round {
            let m = getPlaceholder()
            regulateRatioChild(m)
            caculateChildren.append(m)
        }
        if formattable, regulator.format == .between || regulator.format == .round {
            // 需要插值计算
            currentChildren.enumerated().forEach { idx, m in
                caculateChildren.append(m)
                if idx != currentChildren.count - 1 {
                    let m = getPlaceholder()
                    regulateRatioChild(m)
                    caculateChildren.append(m)
                }
            }
        } else {
            // 计算正常主轴比例
            ratioMainMeasures.forEach { regulateRatioChild($0) }
            caculateChildren.append(contentsOf: currentChildren)
        }

        // 插入尾format
        if formattable, regulator.format == .center || regulator.format == .round {
            let m = getPlaceholder()
            regulateRatioChild(m)
            caculateChildren.append(m)
        }

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

    class Placeholder: Measure {}
//    private lazy var placeholders = [Measure]()
    private func getPlaceholder() -> Measure {
//        let m = MeasureFactory.getPlaceholder()
        let m = Placeholder()
        let calSize = CalSize(main: .fill, cross: .fix(0), direction: regulator.direction)
        m.size = calSize.getSize()
//        var edges = m.margin.getCalEdges(by: regulator.direction)
        // 占位节点需要抵消间距
//        edges.start = -2 * regulator.space
//        m.margin = edges.getInsets()
//        placeholders.append(m)
        return m
    }

    deinit {
//        MeasureFactory.recyclePlaceholders(placeholders)
    }

    private func getCurrentRemainSizeForNormalChildren() -> CalFixedSize {
        let size = CalFixedSize(main: max(0, regRemainCalSize.main - totalSubMain - totalSpace),
                            cross: max(0, regRemainCalSize.cross),
                            direction: regDirection)
        return size
    }

    private func getCurrentRemainSizeForRatioChildren(measure: Measure) -> CalFixedSize {
        let calSize = measure.size.getCalSize(by: regDirection)
        let mainMax = max(0, (calSize.main.ratio / totalMainRatio) * (regRemainCalSize.main - totalSubMain - totalSpace))
        return CalFixedSize(main: mainMax, cross: max(0, regRemainCalSize.cross), direction: regDirection)
    }

    private func appendAndRegulateNormalChild(_ measure: Measure) {
        caculateChildren.append(measure)
        /// 子margin
        let subCalMargin = CalEdges(insets: measure.margin, direction: regDirection)
        // 累计margin
//        totalSubMainMargin += subCalMargin.mainFixed

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
            NewCaculator.applyMeasure(measure, size: subEstimateSize, currentRemain: subRemain, ratio: nil)
            // 记录最大cross
            let subFixedSize = CalFixedSize(cgSize: measure.py_size, direction: regDirection)
            maxCross = max(subFixedSize.cross + subCalMargin.crossFixed, maxCross)
            // 累计main长度
            totalSubMain += (subFixedSize.main + subCalMargin.mainFixed)

            if regulator.caculateChildrenImmediately {
                _ = measure.caculate(byParent: regulator, remain: Caculator.remainSize(with: measure.py_size, margin: measure.margin))
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
        NewCaculator.applyMeasure(measure, size: subEstimateSize, currentRemain: subRemain, ratio: nil)
        // 记录最大cross
        let subFixedSize = CalFixedSize(cgSize: measure.py_size, direction: regDirection)
        maxCross = max(subFixedSize.cross + subCalMargin.crossFixed, maxCross)
        
        if regulator.caculateChildrenImmediately {
            _ = measure.caculate(byParent: regulator, remain: Caculator.remainSize(with: measure.py_size, margin: measure.margin))
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
        for idx in 0 ..< measures.count {
            var index = idx
            if reversed {
                index = measures.count - index - 1
            }
            lastEnd = _caculateCenter(measure: measures[index], at: idx, from: lastEnd)
        }

        if regulator.format == .trailing {
            // 如果格式化为靠后，则需要最后重排一遍
            // 计算最后一个需要移动的距离
            let delta = regRemainCalSize.main - regCalPadding.end - lastEnd + regCalPadding.mainFixed
            measures.forEach { m in
                var calCenter = m.py_center.getCalCenter(by: regulator.direction)
                calCenter.main += delta
                m.py_center = calCenter.getPoint()
            }
        }

        return lastEnd
    }

    private func _caculateCenter(measure: Measure, at index: Int, from end: CGFloat) -> CGFloat {
        let calMargin = CalEdges(insets: measure.margin, direction: regulator.direction)
        let calSize = CalFixedSize(cgSize: measure.py_size, direction: regulator.direction)
        
        // center 占位符需要扣除space
        let isPlaceholder = measure is Placeholder
        let space = (index == 0 || isPlaceholder) ? 0 : regulator.space
        // main = end + 间距 + 自身顶部margin + 自身主轴一半
        let main = end + space + calMargin.start + calSize.main / 2
        

        // cross
        let cross: CGFloat
        let alignment = measure.alignment.contains(.none) ? regulator.justifyContent : measure.alignment

        var calCrossSize = regRemainCalSize.cross + regCalPadding.crossFixed
        if regCalSize.cross.isWrap {
            // 如果是包裹，则需要使用当前最大cross进行计算
            calCrossSize = maxCross + regCalPadding.crossFixed
        }

        if alignment.isCenter(for: regulator.direction) {
            cross = calCrossSize / 2

        } else if alignment.isBackward(for: regulator.direction) {
            cross = calCrossSize - (regCalPadding.backward + calMargin.backward + calSize.cross / 2)
        } else {
            // 若无设置，则默认forward
            cross = calSize.cross / 2 + regCalPadding.forward + calMargin.forward
        }

        let center = CalCenter(main: main, cross: cross, direction: regulator.direction).getPoint()
        measure.py_center = center

        return main + calSize.main / 2 + calMargin.end
    }

    private func _getEstimateSize(measure: Measure, remain: CGSize) -> Size {
        // 非包裹大小，可直接返回计算
        if measure.size.bothNotWrap() {
            return measure.size
        }
        return measure.caculate(byParent: regulator, remain: remain)
    }

    private func _setNotFormattable() {
        print("Constraint error!!! Regulator[\(regulator)] Format.\(regulator.format) reset to .leading")
        formattable = false
        regulator.format = .leading
    }
}
