//
//  Caculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import Foundation

struct CalSize {
    var main: SizeType
    var cross: SizeType
    init(main: SizeType, cross: SizeType) {
        self.main = main
        self.cross = cross
    }
    init(size: Size, direction: Direction) {
        if case .x = direction {
            main = size.width
            cross = size.height
        } else {
            main = size.height
            cross = size.width
        }
    }
    
    func size(by direction: Direction) -> Size {
        if case .x = direction {
            return Size(width: main, height: cross)
        } else {
            return Size(width: cross, height: main)
        }
    }
    
}

struct CalFixedSize {
    var main: CGFloat
    var cross: CGFloat
    init(main: CGFloat, cross: CGFloat) {
        self.main = main
        self.cross = cross
    }
    init(cgSize: CGSize, direction: Direction) {
        if case .x = direction {
            main = cgSize.width
            cross = cgSize.height
        } else {
            main = cgSize.height
            cross = cgSize.width
        }
    }
    
    func cgSize(by direction: Direction) -> CGSize {
        if case .x = direction {
            return CGSize(width: main, height: cross)
        } else {
            return CGSize(width: cross, height: main)
        }
    }
}

class MeasureCaculator {
    static func caculate(measure: Measure, byParent parent: Measure) -> Size {
        if !measure.activated {
            return Size()
        }
        
        switch parent {
        case is LineLayout:
//            let parentLayout = parent as! LineLayout
            let parentCGSize = parent.target?.py_size ?? .zero
            
            var widthSize = measure.unit.size.width
            var heightSize = measure.unit.size.height
            
            if case .wrap = widthSize {
                
//                var wrappedSize: CGSize?
//                if case .y = parentLayout.direction {
//                    wrappedSize = measure.target?.py_sizeThatFits(CGSize(width: parentCGSize.width, height: 0))
//                } else {
//                    wrappedSize = measure.target?.py_sizeThatFits(CGSize(width: 0, height: parentCGSize.height))
//                }
                
                //                mainSize = PuyoUtil.fixedSize(by: parentLayout.direction, cgSize: wrappedSize).main
//                widthSize = PuyoUtil.size(from: wrappedSize, parentDirection: parentLayout.direction).main
                let wrappedCGSize = measure.target?.py_sizeThatFits(CGSize(width: 0, height: parentCGSize.height))
                widthSize = .fixed(wrappedCGSize?.width ?? 0)
            }
            
            if case .wrap = heightSize {
//                var wrappedSize: CGSize?
//                if case .y = parentLayout.direction {
//                    wrappedSize = measure.target?.py_sizeThatFits(CGSize(width: 0, height: parentCGSize.height))
//                } else {
//                    wrappedSize = measure.target?.py_sizeThatFits(CGSize(width: parentCGSize.width, height: 0))
//                }
//                //                crossSize = PuyoUtil.fixedSize(by: parentLayout.direction, cgSize: wrappedSize).cross
//                heightSize = PuyoUtil.size(from: wrappedSize, parentDirection: parentLayout.direction).cross
                let wrappedCGSize = measure.target?.py_sizeThatFits(CGSize(width: 0, height: parentCGSize.height))
                heightSize = .fixed(wrappedCGSize?.height ?? 0)
            }
            
            return Size(width: widthSize, height: heightSize)
        case is ZLayout:
            break
        default:
            break
        }
        
        return Size()
        /*
        if measure.ignore {
            return Size()
        }
        
        switch parent {
        case is LineLayout:
            
            let parentLayout = parent as! LineLayout
            let parentCGSize = parent.target?.py_size ?? .zero
            
            var mainSize = measure.size.main
            if case .wrap = mainSize {
                var wrappedSize: CGSize?
                if case .y = parentLayout.direction {
                    wrappedSize = measure.target?.py_sizeThatFits(CGSize(width: parentCGSize.width, height: 0))
                } else {
                    wrappedSize = measure.target?.py_sizeThatFits(CGSize(width: 0, height: parentCGSize.height))
                }
                
//                mainSize = PuyoUtil.fixedSize(by: parentLayout.direction, cgSize: wrappedSize).main
                mainSize = PuyoUtil.size(from: wrappedSize, parentDirection: parentLayout.direction).main
            }
            
            var crossSize = measure.size.cross
            if case .wrap = crossSize {
                var wrappedSize: CGSize?
                if case .y = parentLayout.direction {
                    wrappedSize = measure.target?.py_sizeThatFits(CGSize(width: 0, height: parentCGSize.height))
                } else {
                    wrappedSize = measure.target?.py_sizeThatFits(CGSize(width: parentCGSize.width, height: 0))
                }
//                crossSize = PuyoUtil.fixedSize(by: parentLayout.direction, cgSize: wrappedSize).cross
                crossSize = PuyoUtil.size(from: wrappedSize, parentDirection: parentLayout.direction).cross
            }
            
            return Size(main: mainSize, cross: crossSize)
            
        case is ZLayout: return Size()
            
        default: fatalError()
        }
        */
    }
}

class LineCaculator {
    
    /// 计算本身布局属性，可能返回的size 为 .fixed, .ratio, 不可能返回wrap
    static func caculateLine(_ layout: LineLayout, from parent: Measure) -> Size {
        // 在此需要假定layout的尺寸已经计算好了
        // 计算全部换算成为main cross
        
        let layoutSize = CalFixedSize(cgSize: layout.target?.py_size ?? .zero, direction: layout.direction)
        
        var totalFixedMain = layout.padding.start + layout.padding.end
        var maxCross: CGFloat = 0
        var totalMainRatio: CGFloat = 0
        var ratioMeasures = [Measure]()

        var caculateChildren = layout.children.filter({ $0.activated })
        if case .sides = layout.formation, caculateChildren.count > 1 {
            // sides formation
            let placeHolder = (0..<caculateChildren.count).map({ _ -> Measure in
                let measure = PlaceHolderMeasure()
                measure.unit.size = CalSize(main: .ratio(1), cross: .fixed(0)).size(by: layout.direction)
                return measure
            })
            caculateChildren = zip(caculateChildren, placeHolder).flatMap({[$0, $1]}).dropLast()
            
        } else if case .center = layout.formation, caculateChildren.count > 0 {
            // center formation
            func getPlaceHolder() -> PlaceHolderMeasure {
                let p = PlaceHolderMeasure()
                p.unit.size = CalSize(main: .ratio(1), cross: .fixed(0)).size(by: layout.direction)
                return p
            }
            caculateChildren = [getPlaceHolder()] + caculateChildren + [getPlaceHolder()]
        }
        
        let totalMainSpace = max(CGFloat(caculateChildren.count - 1) * layout.space, 0)
        
        for measure in caculateChildren {
            // 计算size的具体值
            let subSize = measure.caculate(byParent: layout)
            if subSize.width.isWrap || subSize.height.isWrap {
                fatalError("计算后的尺寸不能是包裹")
            }
            
            // 校验父子size冲突
            check(parent: layout.unit.size.width, child: measure.unit.size.width)
            check(parent: layout.unit.size.height, child: measure.unit.size.height)
            
            // main
            
//            let subMainSize = subSize.getMain(parent: layout.direction)
            let subCalSize = CalSize(size: subSize, direction: layout.direction)
            if case .ratio(let ratio) = subCalSize.main {
                // 需要保存起来，最后计算
//                ratioCaculator.append(measure: measure)
                ratioMeasures.append(measure)
                totalMainRatio += ratio
                totalFixedMain += (measure.margin.start + measure.margin.end)
            } else {
                // cross
                var subCrossSize = subCalSize.cross
                if case .ratio(let ratio) = subCalSize.cross {
//                    subCrossSize = .fixed((layoutPosition.cross - layout.padding.forward - layout.padding.backward) * ratio)
                    subCrossSize = .fixed((layoutSize.cross - layout.padding.forward - layout.padding.backward) * ratio)
                }
                // 设置具体size
                //                measure.target?.py_size = PuyoUtil.cgSize(from: Size(main: subMainSize, cross: subCrossSize), by: layout.direction)
//                measure.target?.py_size = PuyoUtil.cgSize(from: Size(main: subMainSize, cross: subCrossSize), parentDirection: layout.direction)
                measure.target?.py_size = CalFixedSize(main: subCalSize.main.value, cross: subCrossSize.value).cgSize(by: layout.direction)
                // 记录最大cross
                maxCross = max(subCrossSize.value + measure.margin.forward + measure.margin.backward, maxCross)
                totalFixedMain += (subCalSize.main.value + measure.margin.start + measure.margin.end)
            }
        }
        
        // 计算剩余比重值
        for measure in ratioMeasures {
            //            let subSize = measure.caculate(by: direction)
            let subSize = measure.caculate(byParent: layout)
            let calSize = CalSize(size: subSize, direction: layout.direction)
            // cross
            var subCrossSize = calSize.cross
            if case .ratio(let ratio) = subCrossSize {
//                subCrossSize = .fixed((layoutPosition.cross - layout.padding.forward - layout.padding.backward) * ratio)
                subCrossSize = .fixed((layoutSize.cross - layout.padding.forward - layout.padding.backward) * ratio)
            }
            
            //            let subMainSize = SizeType.fixed((subSize.main.value / totalRatio) * layoutPosition.main)
            let subMainSize = SizeType.fixed((calSize.main.value / totalMainRatio) * (layoutSize.main - totalFixedMain - totalMainSpace))
            
            //            measure.target?.py_size = PuyoUtil.cgSize(from: Size(main: subMainSize, cross: subCrossSize), by: layout.direction)
//            measure.target?.py_size = PuyoUtil.cgSize(from: Size(main: subMainSize, cross: subCrossSize), parentDirection: layout.direction)
            measure.target?.py_size = CalFixedSize(main: subMainSize.value, cross: subCrossSize.value).cgSize(by: layout.direction)
            maxCross = max(subCrossSize.value, maxCross)
        }
        
        // 计算center
        var lastEnd: CGFloat = 0
        for (idx, measure) in caculateChildren.enumerated() {
//            lastEnd = _caculateCenter(measure: measure, in: layout, layoutPosition: layoutSize, at: idx, from: lastEnd)
            lastEnd = _caculateCenter(measure: measure, in: layout, layoutSize: layoutSize, at: idx, from: lastEnd)
        }
        
        // 计算自身大小
        var main = layout.unit.size.getMain(parent: parent.direction)
        if main.isWrap {
            if parent.direction == layout.direction {
                main = .fixed(lastEnd + layout.padding.end)
            } else {
                main = .fixed(maxCross + layout.padding.forward + layout.padding.backward)
            }
        }
        var cross = layout.unit.size.getCross(parent: parent.direction)
        if cross.isWrap {
            if parent.direction == layout.direction {
                cross = .fixed(maxCross + layout.padding.forward + layout.padding.backward)
            } else {
                cross = .fixed(lastEnd + layout.padding.end)
            }
        }

        return CalSize(main: main, cross: cross).size(by: parent.direction)
        
//        return Size(main: main, cross: cross)
        
        /*
        
        var maxCross: CGFloat = 0
        
        var ratioCaculateMeasure = [Measure]()
        var totalRatio: CGFloat = 0
        var totalFixedMain: CGFloat = layout.padding.start + layout.padding.end
//        let layoutPosition = PuyoUtil.fixedPosition(from: layout.target?.py_size, by: layout.direction)
        let layoutPosition = PuyoUtil.fixedSize(from: layout.target?.py_size, parentDirection: layout.direction)
        
        var caculatingChildren = layout.children.filter({ !$0.ignore })
        
        if case .sides = layout.formation, caculatingChildren.count > 1 {
            // sides formation
            let placeHolder = (0..<caculatingChildren.count).map({ _ -> Measure in
                let measure = PlaceHolderMeasure()
                measure.size.main = .ratio(1)
                return measure
            })
            caculatingChildren = zip(caculatingChildren, placeHolder).flatMap({[$0, $1]}).dropLast()
            
        } else if case .center = layout.formation, caculatingChildren.count > 0 {
            // center formation
            func getPlaceHolder() -> PlaceHolderMeasure {
                let p = PlaceHolderMeasure()
                p.size.main = .ratio(1)
                return p
            }
            caculatingChildren = [getPlaceHolder()] + caculatingChildren + [getPlaceHolder()]
        }
        
        let totalMainSpace = max(CGFloat(caculatingChildren.count - 1) * layout.space, 0)
        
        for measure in caculatingChildren {
            // 计算子size的具体值
            let subSize = measure.caculate(from: layout)
            
            guard !subSize.main.isWrap && !subSize.cross.isWrap else {
                fatalError()
            }
            
            // 校验父子依赖冲突
            let parentWidth = PuyoUtil.widthSize(from: layout.size, parentDirection: parent.direction)
            let childWidth = PuyoUtil.widthSize(from: subSize, parentDirection: layout.direction)
            check(parent: parentWidth, child: childWidth)
            
            let parentHeight = PuyoUtil.heightSize(from: layout.size, parentDirection: parent.direction)
            let childHeight = PuyoUtil.heightSize(from: subSize, parentDirection: layout.direction)
            check(parent: parentHeight, child: childHeight)
            
//            check(parent: layout.size.main, child: subSize.main)
//            check(parent: layout.size.cross, child: subSize.cross)
            
            // main
            let subMainSize = subSize.main
            if case .ratio(let ratio) = subMainSize {
                // 需要保存起来，最后计算
                totalRatio += ratio
                ratioCaculateMeasure.append(measure)
                
                totalFixedMain += (measure.margin.start + measure.margin.end)
            } else {
                // cross
                var subCrossSize = subSize.cross
                if case .ratio(let ratio) = subCrossSize {
                    subCrossSize = .fixed((layoutPosition.cross - layout.padding.forward - layout.padding.backward) * ratio)
                }
                // 设置具体size
//                measure.target?.py_size = PuyoUtil.cgSize(from: Size(main: subMainSize, cross: subCrossSize), by: layout.direction)
                measure.target?.py_size = PuyoUtil.cgSize(from: Size(main: subMainSize, cross: subCrossSize), parentDirection: layout.direction)
                // 记录最大cross
                maxCross = max(subCrossSize.value + measure.margin.forward + measure.margin.backward, maxCross)
                totalFixedMain += (subMainSize.value + measure.margin.start + measure.margin.end)
            }
            
        }
        
        // 计算剩余比重值
        for measure in ratioCaculateMeasure {
//            let subSize = measure.caculate(by: direction)
            let subSize = measure.caculate(from: layout)
            // cross
            var subCrossSize = subSize.cross
            if case .ratio(let ratio) = subCrossSize {
                subCrossSize = .fixed((layoutPosition.cross - layout.padding.forward - layout.padding.backward) * ratio)
            }
            
//            let subMainSize = SizeType.fixed((subSize.main.value / totalRatio) * layoutPosition.main)
            let subMainSize = SizeType.fixed((subSize.main.value / totalRatio) * (layoutPosition.main - totalFixedMain - totalMainSpace))
            
//            measure.target?.py_size = PuyoUtil.cgSize(from: Size(main: subMainSize, cross: subCrossSize), by: layout.direction)
            measure.target?.py_size = PuyoUtil.cgSize(from: Size(main: subMainSize, cross: subCrossSize), parentDirection: layout.direction)
            maxCross = max(subCrossSize.value, maxCross)
        }
        
        // 计算center
        var lastEnd: CGFloat = 0
        for (idx, measure) in caculatingChildren.enumerated() {
            lastEnd = _caculateCenter(measure: measure, in: layout, layoutPosition: layoutPosition, at: idx, from: lastEnd)
        }
        
        // 计算自身大小
        var main = layout.size.main
        if main.isWrap {
            if parent.direction == layout.direction {
                main = .fixed(lastEnd + layout.padding.end)
            } else {
                main = .fixed(maxCross + layout.padding.forward + layout.padding.backward)
            }
        }
        var cross = layout.size.cross
        if cross.isWrap {
            if parent.direction == layout.direction {
                cross = .fixed(maxCross + layout.padding.forward + layout.padding.backward)
            } else {
                cross = .fixed(lastEnd + layout.padding.end)
            }
        }
        
        return Size(main: main, cross: cross)
         */
    }
        
    private static func _caculateCenter(measure: Measure,
                                        in layout: LineLayout,
                                        layoutSize: CalFixedSize,
                                        at index: Int,
                                        from end: CGFloat) -> CGFloat {
        var lastEnd = end
        if index == 0 {
            lastEnd = layout.padding.start
        }
        
//        let fixedSubSize = PuyoUtil.fixedSize(by: layout.direction, cgSize: measure.target?.py_size)
//        let fixedSubSize = PuyoUtil.size(from: measure.target?.py_size, parentDirection: layout.direction)
        let fixedSize = CalFixedSize(cgSize: measure.target?.py_size ?? .zero, direction: layout.direction)
        
        // main = last.main + layout.space + measure.margin.start + fixedSubSize.main / 2
        let main = lastEnd + (index == 0 ? 0 : layout.space) + measure.margin.start + fixedSize.main / 2
        
        // cross =
        let aligment = measure.aligment != .none ? measure.aligment : (layout.crossAxis == .none ? .forward : layout.crossAxis)
        let cross: CGFloat
        switch aligment {
        case .center:
            cross = layoutSize.cross / 2
        case .forward:
            cross = fixedSize.cross / 2 + layout.padding.forward + measure.margin.forward
        case .backward:
            cross = layoutSize.cross - (fixedSize.cross / 2 + layout.padding.backward + measure.margin.backward)
        default:
            cross = fixedSize.cross / 2
        }
        
        let center = Offset(main: main, cross: cross)
//        measure.target?.py_center = PuyoUtil.point(from: center, fixedPosition: layoutPosition, by: layout.direction, reverse: layout.reverse)
        measure.target?.py_center = PuyoUtil.point(from: center, fixedSize: layoutSize, by: layout.direction, reverse: layout.reverse)
        
        // 返回bottom
        return center.main + fixedSize.main / 2 + measure.margin.end
    }
    
    private static func check(parent: SizeType, child: SizeType) {
        // 当父依赖子时，子不能依赖父
        switch (parent, child) {
        case (.wrap, .ratio(_)):
            fatalError("parent and child in a dependency cycle!!!!")
        default: break
        }
    }
}
