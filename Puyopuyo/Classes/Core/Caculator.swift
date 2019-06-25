//
//  Caculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import Foundation

class MeasureCaculator {
    static func caculate(measure: Measure, from parent: Measure) -> Size {
        
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
        /*
         let parentSize = PuyoUtil.cgSize(from: parent, direction: direction)
         
         var mainSize = size.main
         if case .wrap = mainSize {
         var wrapSize: CGSize?
         if case .y = direction {
         wrapSize = target?.py_sizeThatFits(CGSize(width: parentSize.width, height: 0))
         } else {
         wrapSize = target?.py_sizeThatFits(CGSize(width: 0, height: parentSize.height))
         }
         
         mainSize = PuyoUtil.fixedSize(by: direction, cgSize: wrapSize).main
         }
         
         var crossSize = size.cross
         if case .wrap = crossSize {
         
         var wrapSize: CGSize?
         if case .y = direction {
         wrapSize = target?.py_sizeThatFits(CGSize(width: 0, height: parentSize.height))
         } else {
         wrapSize = target?.py_sizeThatFits(CGSize(width: parentSize.width, height: 0))
         }
         crossSize = PuyoUtil.fixedSize(by: direction, cgSize: wrapSize).cross
         }
         return Size(main: mainSize, cross: crossSize)
         */

    }
}

class LineCaculator {
    
    /// 计算本身布局属性，可能返回的size 为 .fixed, .ratio, 不可能返回wrap
    static func caculateLine(_ layout: LineLayout, from parent: Measure) -> Size {
        // 在此需要假定layout的尺寸已经计算好了
        
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
    }
    
    private static func _caculateCenter(measure: Measure,
                                        in layout: LineLayout,
                                        layoutPosition: FixedSize,
                                        at index: Int,
                                        from end: CGFloat) -> CGFloat {
        var lastEnd = end
        if index == 0 {
            lastEnd = layout.padding.start
        }
        
//        let fixedSubSize = PuyoUtil.fixedSize(by: layout.direction, cgSize: measure.target?.py_size)
        let fixedSubSize = PuyoUtil.size(from: measure.target?.py_size, parentDirection: layout.direction)
        
        // main = last.main + layout.space + measure.margin.start + fixedSubSize.main / 2
        let main = lastEnd + (index == 0 ? 0 : layout.space) + measure.margin.start + fixedSubSize.main.value / 2
        
        // cross =
        let aligment = measure.aligment != .none ? measure.aligment : (layout.crossAxis == .none ? .forward : layout.crossAxis)
        let cross: CGFloat
        switch aligment {
        case .center:
            cross = layoutPosition.cross / 2
        case .forward:
            cross = fixedSubSize.cross.value / 2 + layout.padding.forward + measure.margin.forward
        case .backward:
            cross = layoutPosition.cross - (fixedSubSize.cross.value / 2 + layout.padding.backward + measure.margin.backward)
        default:
            cross = fixedSubSize.cross.value / 2
        }
        
        let center = Offset(main: main, cross: cross)
        measure.target?.py_center = PuyoUtil.point(from: center, fixedPosition: layoutPosition, by: layout.direction, reverse: layout.reverse)
        
        // 返回bottom
        return center.main + fixedSubSize.main.value / 2 + measure.margin.end
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
