//
//  FlowCaculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

class FlowCaculator {
    
    let layout: FlowLayout
    let parent: Measure
//    var rows: [FlowRow]
    let activeChildren: [Measure]
    var arrangeCount: Int
    let totalRow: Int
    
    init(_ layout: FlowLayout, parent: Measure) {
        self.layout = layout
        self.parent = parent
        var mainHasRatio = false
        var crossHasRatio = false
        var children = [Measure]()
        layout.enumerateChild { (_, m) in
            guard m.activated else {
                return
            }
            let calSize = CalSize(size: m.size, direction: layout.direction)
            if calSize.main.isRatio && !mainHasRatio {
                mainHasRatio = true
            }
            if calSize.cross.isRatio && !crossHasRatio {
                crossHasRatio = true
            }
            children.append(m)
        }
        activeChildren = children
        arrangeCount = layout.arrangeCount
        
        var row = activeChildren.count / layout.arrangeCount
        if activeChildren.count % layout.arrangeCount > 0 {
            row += 1
        }
        totalRow = row
//        var column = layout.arrangeCount
//
//        if !mainHasRatio {
//            switch layout.formation {
//            case .center:
//                row += 2
//            case .sides:
//                row = row * 2 - 1
//            default: break
//            }
//        } else {
//            // warn
//        }
//
//        if !crossHasRatio {
//            switch layout.subFormation {
//            case .center:
//                column += 2
//            case .sides:
//                column = column * 2 - 1
//            default: break
//            }
//        } else {
//            // warn
//        }
//
//        rows = Array(repeating: FlowRow(column), count: row)
//        placement = Array(repeating: Array(repeating: FlowNode(), count: column), count: row)
    }

    lazy var layoutCalPadding = CalEdges(insets: layout.padding, direction: layout.direction)
    lazy var layoutCalFixedSize = CalFixedSize(cgSize: layout.target?.py_size ?? .zero, direction: layout.direction)
    lazy var layoutCalSize = CalSize(size: layout.size, direction: layout.direction)
    lazy var totalFixedMain: CGFloat = self.layoutCalPadding.start + self.layoutCalPadding.end
    
    func caculate() -> Size {
        // 用flatcaculator进行转化
        for row in 0..<totalRow {
            let rowMeasures = activeChildren[row * arrangeCount..<min(row * arrangeCount + arrangeCount, activeChildren.count)]
            let flat = _FlatLayout(rowMeasures)
            flat.formation = layout.subFormation
            flat.reverse = layout.reverse
            let rowSize = FlatCaculator(flat, parent: Measure()).caculate()
        }
        
        
        return Size()
    }
    
    private func getMainSpace() -> CGFloat {
        if layout.direction == .x {
            return layout.xSpace
        }
        return layout.ySpace
    }
    
    private func getCrossSpace() -> CGFloat {
        if layout.direction == .y {
            return layout.xSpace
        }
        return layout.ySpace
    }
    
    private func caculate(_ row: ArraySlice<Measure>, at index: Int) {
        var crossRatioIndexes = [(row: Int, column: Int)]()
        
        var totalCrossRatio: CGFloat = 0
        row.enumerated().forEach { (column, m) in
            let subSize = m.caculate(byParent: layout)
            let subCalSize = CalSize(size: subSize, direction: layout.direction)
            let subCalMargin = CalEdges(insets: m.margin, direction: layout.direction)
            guard subSize.bothNotWrap() else { fatalError() }

            // 把子节点方式数据结构中
            let place = placeByOrigin(row: index, column: column)
//            rows[place.row].nodes[place.column].measure = m
            
            var crossSize = subCalSize.cross
            if crossSize.isRatio {
                crossRatioIndexes.append((row: index, column: column))
                totalCrossRatio += crossSize.ratio
            } else {
//                var mainSize = subCalSize.main
            }
        }
    }
    
    private func placeByOrigin(row: Int, column: Int) -> (row: Int, column: Int) {
        var newRow = row
        if layout.formation == .center {
            newRow += 1
        } else if layout.formation == .sides {
            newRow *= 2
        }
        
        var newColumn = column
        if layout.subFormation == .center {
            newColumn += 1
        } else if layout.subFormation == .sides {
            newColumn *= 2
        }
        return (row: newRow, column: newColumn)
    }
    
}

struct FlowRow {
    
    struct Node {
        lazy var measure: Measure = {
            let m = PlaceHolderMeasure()
            m.size = Size(width: .ratio(1), height: .ratio(1))
            return m
        }()
        var fixed: Bool = true
        init(_ m: Measure? = nil) {
            if let m = m {
                measure = m
            }
        }
    }
    
    let count: Int
    var nodes: [Node]
    init(_ count: Int) {
        self.count = count
        nodes = Array(repeating: Node(), count: count)
    }
    
    mutating func caculate(measures: ArraySlice<Measure>, layout: FlowLayout, subFormation formation: Formation) {
        
        var totalCrossRatio: CGFloat = 0
        var crossRatioMeasure = [Measure]()
        
        measures.enumerated().forEach { (idx, m) in
            let subSize = m.caculate(byParent: layout)
            let subCalSize = CalSize(size: subSize, direction: layout.direction)
            let subCalMargin = CalEdges(insets: m.margin, direction: layout.direction)
            guard subSize.bothNotWrap() else { fatalError() }
            
            // 把子节点方式数据结构中
            nodes[idx].measure = m
            
            var crossSize = subCalSize.cross
            if crossSize.isRatio {
                totalCrossRatio += crossSize.ratio
                crossRatioMeasure.append(m)
            } else {
                //                var mainSize = subCalSize.main
            }
        }
    }
    
    private func column(_ column: Int, with formation: Formation) -> Int {
        switch formation {
        case .center: return column + 1
        case .sides: return column * 2
        default: return column
        }
    }
}

private class _FlatLayout: FlatLayout {
    var measures: ArraySlice<Measure>
    init(_ measures: ArraySlice<Measure>) {
        self.measures = measures
    }
    override func enumerateChild(_ block: (Int, Measure) -> Void) {
        measures.enumerated().forEach {
            block($0, $1)
        }
    }
}
