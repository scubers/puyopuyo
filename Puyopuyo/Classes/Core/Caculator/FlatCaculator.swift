//
//  LineCaculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

class FlatCaculator {
    
    let layout: FlatLayout
    let parent: Measure
    init(_ layout: FlatLayout, parent: Measure) {
        self.layout = layout
        self.parent = parent
    }
    
    lazy var layoutFixedSize = CalFixedSize(cgSize: self.layout.py_size, direction: layout.direction)
    lazy var layoutCalPadding = CalEdges(insets: layout.padding, direction: layout.direction)
    lazy var layoutCalSize = CalSize(size: layout.size, direction: layout.direction)
    var totalMainRatio: CGFloat = 0
    lazy var totalFixedMain = layoutCalPadding.start + layoutCalPadding.end
    var maxCross: CGFloat = 0
    
    
    /// 计算本身布局属性，可能返回的size 为 .fixed, .ratio, 不可能返回wrap
    func caculate() -> Size {
        
        // 在此需要假定layout的尺寸已经计算好了
        // 计算全部换算成为main cross
        var ratioMeasures = [Measure]()
        
        // 标记主轴是否存在比例项目，若有，则排斥使用formation
        var mainHasRatio = false
        var caculateChildren = [Measure]()
        layout.enumerateChild { (_, m) in
//            return $0.activated
            if m.activated {
                if m.size.getCalSize(by: layout.direction).main.isRatio {
                    mainHasRatio = true
                }
                caculateChildren.append(m)
            }
        }
        
        if case .sides = layout.formation, caculateChildren.count > 1 {
            if mainHasRatio {
                print("Constraint error!!! 主轴上有比例设置，不能与Formation.sides同时存在，Formation重置成leading")
                layout.formation = .leading
            } else {
                // sides formation
                let placeHolder = (0..<caculateChildren.count).map({ _ -> Measure in
                    let measure = Measure()
                    measure.size = CalSize(main: .ratio(1), cross: .fix(0), direction: layout.direction).getSize()
                    return measure
                })
                caculateChildren = zip(caculateChildren, placeHolder).flatMap({[$0, $1]}).dropLast()
            }
            
        } else if case .center = layout.formation, caculateChildren.count > 0 {
            if mainHasRatio {
                print("Constraint error!!! 主轴上有比例设置，不能与Formation.center同时存在，Formation重置成leading")
                layout.formation = .leading
            } else {
                // center formation
                func getPlaceHolder() -> Measure {
                    let p = Measure()
                    p.size = CalSize(main: .ratio(1), cross: .fix(1), direction: layout.direction).getSize()
                    return p
                }
                caculateChildren = [getPlaceHolder()] + caculateChildren + [getPlaceHolder()]
            }
        } else if layout.formation == .round && caculateChildren.count > 0 {
            if mainHasRatio {
                print("Constraint error!!! 主轴上有比例设置，不能与Formation.round同时存在，Formation重置成leading")
                layout.formation = .leading
            } else {
                // center formation
                func getPlaceHolder() -> Measure {
                    let p = Measure()
                    p.size = CalSize(main: .ratio(1), cross: .fix(1), direction: layout.direction).getSize()
                    return p
                }
                let placeHolder = (0..<caculateChildren.count).map({ _ -> Measure in
                    let measure = Measure()
                    measure.size = CalSize(main: .ratio(1), cross: .fix(0), direction: layout.direction).getSize()
                    return measure
                })
                caculateChildren = [getPlaceHolder()] + zip(caculateChildren, placeHolder).flatMap({[$0, $1]})
            }
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
                    subCrossSize = .fix((layoutFixedSize.cross - (layoutCalPadding.forward + layoutCalPadding.backward + subCalMargin.forward + subCalMargin.backward)) * ratio)
                }
                // 设置具体size
                measure.py_size = CalFixedSize(main: subCalSize.main.fixedValue, cross: subCrossSize.fixedValue, direction: layout.direction).getSize()
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
                subCrossSize = .fix((layoutFixedSize.cross - (layoutCalPadding.forward + layoutCalPadding.backward + calMargin.forward + calMargin.backward)) * ratio)
            }
            // main
            let subMainSize = SizeDescription.fix((calSize.main.ratio / totalMainRatio) * (layoutFixedSize.main - totalFixedMain - totalMainSpace))
            measure.py_size = CalFixedSize(main: subMainSize.fixedValue, cross: subCrossSize.fixedValue, direction: layout.direction).getSize()
            maxCross = max(subCrossSize.fixedValue + calMargin.forward + calMargin.backward, maxCross)
        }
        
        // 计算center
        let lastEnd = caculateCenter(measures: caculateChildren)
        
        // 计算自身大小
        var main = layout.size.getMain(parent: parent.direction)
        if main.isWrap {
            if parent.direction == layout.direction {
                main = .fix(main.getWrapSize(by: lastEnd + layoutCalPadding.end))
            } else {
                main = .fix(main.getWrapSize(by: maxCross + layoutCalPadding.crossFixed))
            }
        }
        var cross = layout.size.getCross(parent: parent.direction)
        if cross.isWrap {
            if parent.direction == layout.direction {
                cross = .fix(cross.getWrapSize(by: maxCross + layoutCalPadding.crossFixed))
            } else {
                cross = .fix(cross.getWrapSize(by: lastEnd + layoutCalPadding.end))
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
    /// - Returns: 返回最后节点的end(包括最后一个节点的margin.end)
    private func caculateCenter(measures: [Measure]) -> CGFloat {
        
        var lastEnd: CGFloat = layoutCalPadding.start
        
        var children = measures
        if layout.reverse {
            children.reverse()
        }
        
        for (idx, measure) in children.enumerated() {
            lastEnd = _caculateCenter(measure: measure, at: idx, from: lastEnd)
        }
        
        if layout.formation == .trailing {
            // 如果格式化为靠后，则需要最后重排一遍
            // 计算最后一个需要移动的距离
            let delta = layoutFixedSize.main - layoutCalPadding.end - lastEnd
            if layout.direction == .x {
                children.forEach({ $0.py_center.x += delta })
            } else {
                children.forEach({ $0.py_center.y += delta })
            }
        }
        
        return lastEnd
    }
    
    private func _caculateCenter(measure: Measure, at index: Int, from end: CGFloat) -> CGFloat {
        
        let calMargin = CalEdges(insets: measure.margin, direction: layout.direction)
        let calSize = CalFixedSize(cgSize: measure.py_size, direction: layout.direction)
        let space = (index == 0) ? 0 : layout.space
        
        // main = end + 间距 + 自身顶部margin + 自身主轴一半
        let main = end + space + calMargin.start + calSize.main / 2
        
        // cross
        let cross: CGFloat
        let aligment = measure.aligment.contains(.none) ? layout.justifyContent : measure.aligment
        if aligment.isCenter(for: layout.direction) {
            cross = layoutFixedSize.cross / 2
            
        } else if aligment.isBackward(for: layout.direction) {
            cross = layoutFixedSize.cross - (layoutCalPadding.backward + calMargin.backward + calSize.cross / 2)
        } else {
            // 若无设置，则默认forward
            cross = calSize.cross / 2 + layoutCalPadding.forward + calMargin.forward
        }
        
        let center = CalCenter(main: main, cross: cross, direction: layout.direction).getPoint()
        measure.py_center = center
        
        return main + calSize.main / 2 + calMargin.end
    }
    
}
