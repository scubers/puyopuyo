//
//  LineCaculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

class FlatCaculator {
    
    /// 计算本身布局属性，可能返回的size 为 .fixed, .ratio, 不可能返回wrap
    static func caculateLine(_ layout: FlatLayout, from parent: Measure) -> Size {
        // 在此需要假定layout的尺寸已经计算好了
        // 计算全部换算成为main cross
        
        let layoutFixedSize = CalFixedSize(cgSize: layout.target?.py_size ?? .zero, direction: layout.direction)
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
                p.size = CalSize(main: .ratio(1), cross: .fixed(1), direction: layout.direction).getSize()
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
            
            /// 子margin
            let subCalMargin = CalEdges(insets: measure.margin, direction: layout.direction)
            
            // main
            let subCalSize = CalSize(size: subSize, direction: layout.direction)
            //            if case .ratio(let ratio) = subCalSize.main {
            if subCalSize.main.isRatio {
                // 需要保存起来，最后计算
                ratioMeasures.append(measure)
                totalMainRatio += subCalSize.main.ratio
                totalFixedMain += (subCalMargin.start + subCalMargin.end)
            } else {
                // cross
                var subCrossSize = subCalSize.cross
                //                if case .ratio(let ratio) = subCalSize.cross {
                if subCalSize.cross.isRatio {
                    let ratio = subCalSize.cross.ratio
                    subCrossSize = .fixed((layoutFixedSize.cross - (layoutPadding.forward + layoutPadding.backward + subCalMargin.forward + subCalMargin.backward)) * ratio)
                }
                // 设置具体size
                measure.target?.py_size = CalFixedSize(main: subCalSize.main.fixedValue, cross: subCrossSize.fixedValue, direction: layout.direction).getSize()
                // 记录最大cross
                maxCross = max(subCrossSize.fixedValue + subCalMargin.forward + subCalMargin.backward, maxCross)
                totalFixedMain += (subCalSize.main.fixedValue + subCalMargin.start + subCalMargin.end)
            }
        }
        
        // 计算剩余比重值
        for measure in ratioMeasures {
            let subSize = measure.caculate(byParent: layout)
            let calSize = CalSize(size: subSize, direction: layout.direction)
            let calMargin = CalEdges(insets: measure.margin, direction: layout.direction)
            // cross
            var subCrossSize = calSize.cross
            //            if case .ratio(let ratio) = subCrossSize {
            if subCrossSize.isRatio {
                let ratio = subCrossSize.ratio
                subCrossSize = .fixed((layoutFixedSize.cross - (layoutPadding.forward + layoutPadding.backward + calMargin.forward + calMargin.backward)) * ratio)
            }
            // main
            let subMainSize = SizeDescription.fixed((calSize.main.ratio / totalMainRatio) * (layoutFixedSize.main - totalFixedMain - totalMainSpace))
            measure.target?.py_size = CalFixedSize(main: subMainSize.fixedValue, cross: subCrossSize.fixedValue, direction: layout.direction).getSize()
            maxCross = max(subCrossSize.fixedValue + calMargin.forward + calMargin.backward, maxCross)
        }
        
        // 计算center
        let lastEnd = caculate(caculateChildren, parent: layout)
        
        // 计算自身大小
        var main = layout.size.getMain(parent: parent.direction)
        if main.isWrap {
            if parent.direction == layout.direction {
                main = .fixed(main.getWrapSize(by: lastEnd + layoutPadding.end))
            } else {
                main = .fixed(main.getWrapSize(by: maxCross + layoutPadding.forward + layoutPadding.backward))
            }
        }
        var cross = layout.size.getCross(parent: parent.direction)
        if cross.isWrap {
            if parent.direction == layout.direction {
                cross = .fixed(cross.getWrapSize(by: maxCross + layoutPadding.forward + layoutPadding.backward))
            } else {
                cross = .fixed(cross.getWrapSize(by: lastEnd + layoutPadding.end))
            }
        }
        
        return CalSize(main: main, cross: cross, direction: parent.direction).getSize()
        
    }
    
    private static func check(parent: SizeDescription, child: SizeDescription) {
        // 当父依赖子时，子不能依赖父
        if parent.isWrap && child.isRatio {
            fatalError("parent and child in a dependency cycle!!!!")
        }
    }
    
    /// 这里为measures的大小都计算好，需要计算每个节点的center
    ///
    /// - Parameters:
    ///   - measures: 已经计算好大小的节点
    ///   - parent: 处于的父layout
    /// - Returns: 返回最后节点的end(包括最后一个节点的margin.end)
    private static func caculate(_ measures: [Measure], parent: FlatLayout) -> CGFloat {
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
                                        in layout: FlatLayout,
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
        let aligment = measure.aligment.contains(.none) ? layout.justifyContent : measure.aligment
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
    
    private static func point(from center: CalCenter, layoutSize: CalFixedSize, by layout: FlatLayout) -> CGPoint {
        var point: CGPoint
        if case .y = layout.direction {
            point = CGPoint(x: center.cross, y: center.main)
        } else {
            point = CGPoint(x: center.main, y: layoutSize.cross - center.cross)
        }
        return point
    }
    
}
