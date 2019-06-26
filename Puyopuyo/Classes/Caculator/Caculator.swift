//
//  Caculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import Foundation

class MeasureCaculator {
    static func caculate(measure: Measure, byParent parent: Measure) -> Size {
        if !measure.activated {
            return Size()
        }
        
        switch parent {
        case is LineLayout:
//            let parentLayout = parent as! LineLayout
            let parentCGSize = parent.target?.py_size ?? .zero
            
            var widthSize = measure.size.width
            var heightSize = measure.size.height
            
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
        let layoutPadding = CalEdges(insets: layout.padding, direction: layout.direction)
        
        var totalFixedMain = layoutPadding.start + layoutPadding.end
        var maxCross: CGFloat = 0
        var totalMainRatio: CGFloat = 0
        var ratioMeasures = [Measure]()

        var caculateChildren = layout.children.filter({ $0.activated })
        
        if case .sides = layout.formation, caculateChildren.count > 1 {
            // sides formation
            let placeHolder = (0..<caculateChildren.count).map({ _ -> Measure in
                let measure = PlaceHolderMeasure()
                measure.size = CalSize(main: .ratio(1), cross: .fixed(0), direction: layout.direction).getSize()
                return measure
            })
            caculateChildren = zip(caculateChildren, placeHolder).flatMap({[$0, $1]}).dropLast()
            
        } else if case .center = layout.formation, caculateChildren.count > 0 {
            // center formation
            func getPlaceHolder() -> PlaceHolderMeasure {
                let p = PlaceHolderMeasure()
                p.size = CalSize(main: .ratio(1), cross: .fixed(0), direction: layout.direction).getSize()
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
            check(parent: layout.size.width, child: measure.size.width)
            check(parent: layout.size.height, child: measure.size.height)
            
            
            /// 子margin
            let calMargin = CalEdges(insets: measure.margin, direction: layout.direction)
            
            // main
            let subCalSize = CalSize(size: subSize, direction: layout.direction)
            if case .ratio(let ratio) = subCalSize.main {
                // 需要保存起来，最后计算
                ratioMeasures.append(measure)
                totalMainRatio += ratio
                let calMargin = CalEdges(insets: measure.margin, direction: layout.direction)
                totalFixedMain += (calMargin.start + calMargin.end)
            } else {
                // cross
                var subCrossSize = subCalSize.cross
                if case .ratio(let ratio) = subCalSize.cross {
                    subCrossSize = .fixed((layoutSize.cross - (layoutPadding.forward + layoutPadding.backward + calMargin.forward + calMargin.backward)) * ratio)
                }
                // 设置具体size
                measure.target?.py_size = CalFixedSize(main: subCalSize.main.value, cross: subCrossSize.value, direction: layout.direction).getSize()
                // 记录最大cross
                maxCross = max(subCrossSize.value + calMargin.forward + calMargin.backward, maxCross)
                totalFixedMain += (subCalSize.main.value + calMargin.start + calMargin.end)
            }
        }
        
        // 计算剩余比重值
        for measure in ratioMeasures {
            let subSize = measure.caculate(byParent: layout)
            let calSize = CalSize(size: subSize, direction: layout.direction)
            let calMargin = CalEdges(insets: measure.margin, direction: layout.direction)
            // cross
            var subCrossSize = calSize.cross
            if case .ratio(let ratio) = subCrossSize {
                subCrossSize = .fixed((layoutSize.cross - (layoutPadding.forward + layoutPadding.backward + calMargin.forward + calMargin.backward)) * ratio)
            }
            // main
            let subMainSize = SizeType.fixed((calSize.main.value / totalMainRatio) * (layoutSize.main - totalFixedMain - totalMainSpace))
            measure.target?.py_size = CalFixedSize(main: subMainSize.value, cross: subCrossSize.value, direction: layout.direction).getSize()
            maxCross = max(subCrossSize.value + calMargin.forward + calMargin.backward, maxCross)
        }
        
        // 计算center
        let lastEnd = caculate(caculateChildren, parent: layout)
        
        // 计算自身大小
        var main = layout.size.getMain(parent: parent.direction)
        if main.isWrap {
            if parent.direction == layout.direction {
                main = .fixed(lastEnd + layoutPadding.end)
            } else {
                main = .fixed(maxCross + layoutPadding.forward + layoutPadding.backward)
            }
        }
        var cross = layout.size.getCross(parent: parent.direction)
        if cross.isWrap {
            if parent.direction == layout.direction {
                cross = .fixed(maxCross + layoutPadding.forward + layoutPadding.backward)
            } else {
                cross = .fixed(lastEnd + layoutPadding.end)
            }
        }

        return CalSize(main: main, cross: cross, direction: parent.direction).getSize()
        
    }
    
    private static func check(parent: SizeType, child: SizeType) {
        // 当父依赖子时，子不能依赖父
        switch (parent, child) {
        case (.wrap, .ratio(_)):
            fatalError("parent and child in a dependency cycle!!!!")
        default: break
        }
    }
    
    /// 这里为measures的大小都计算好，需要计算每个节点的center
    ///
    /// - Parameters:
    ///   - measures: 已经计算好大小的节点
    ///   - parent: 处于的父layout
    /// - Returns: 返回最后节点的end(包括最后一个节点的margin.end)
    private static func caculate(_ measures: [Measure], parent: LineLayout) -> CGFloat {
        let layoutSize = CalFixedSize(cgSize: parent.target?.py_size ?? .zero, direction: parent.direction)
        let calPadding = CalEdges(insets: parent.padding, direction: parent.direction)
        
        var lastEnd: CGFloat = calPadding.start
        
        var children = measures
        if parent.reverse {
            children.reverse()
        }
        
        for (idx, measure) in children.enumerated() {
            lastEnd = _caculateCenter(measure: measure, in: parent, layoutSize: layoutSize, at: idx, from: lastEnd)
        }
        
        if parent.formation == .trailing {
            // 如果格式化为靠后，则需要最后重排一遍
            // 计算最后一个需要移动的距离
            let delta = layoutSize.main - calPadding.end - lastEnd
            if parent.direction == .x {
                children.forEach({ $0.target?.py_center.x += delta })
            } else {
                children.forEach({ $0.target?.py_center.y += delta })
            }
        }
        
        return lastEnd
    }
    
    private static func _caculateCenter(measure: Measure,
                                        in layout: LineLayout,
                                        layoutSize: CalFixedSize,
                                        at index: Int,
                                        from end: CGFloat) -> CGFloat {
        
        let layoutPadding = CalEdges(insets: layout.padding, direction: layout.direction)
        let calMargin = CalEdges(insets: measure.margin, direction: layout.direction)
        let calSize = CalFixedSize(cgSize: measure.target?.py_size ?? .zero, direction: layout.direction)
        let space = (index == 0) ? 0 : layout.space
        
        // main = end + 间距 + 自身顶部margin + 自身主轴一半
        let main = end + space + calMargin.start + calSize.main / 2
        
        // cross
        let cross: CGFloat
        let aligment = measure.aligment.contains(.none) ? layout.crossAxis : measure.aligment
        if aligment.isCenter() {
            cross = layoutSize.cross / 2
            
        } else if aligment.isForward(for: layout.direction) {
            cross = calSize.cross / 2 + layoutPadding.forward + calMargin.forward
            
        } else if aligment.isBackward(for: layout.direction) {
            cross = layoutSize.cross - (layoutPadding.backward + calMargin.backward + calSize.cross / 2)
            
        } else {
            fatalError("")
        }
        
        let center = point(from: CalCenter(main: main, cross: cross), layoutSize: layoutSize, by: layout)
        measure.target?.py_center = center
        
        return main + calSize.main / 2 + calMargin.end
    }
    
    private static func point(from center: CalCenter, layoutSize: CalFixedSize, by layout: LineLayout) -> CGPoint {
        var point: CGPoint
        if case .y = layout.direction {
            point = CGPoint(x: center.cross, y: center.main)
        } else {
            point = CGPoint(x: center.main, y: layoutSize.cross - center.cross)
        }
        return point
    }

}
