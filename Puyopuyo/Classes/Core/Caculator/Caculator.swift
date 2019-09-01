//
//  Caculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import Foundation

class Caculator {
    
    /// 计算非wrap的size
    static func caculate(size: Size, by cgSize: CGSize) -> Size {
        let width = caculateFix(size.width, by: cgSize.width)
        let height = caculateFix(size.height, by: cgSize.height)
        return Size(width: width, height: height)
    }
    
    static func caculateFix(_ size: SizeDescription, by relayLength: CGFloat) -> SizeDescription {
        guard !size.isWrap else {
            fatalError("不能计算包裹尺寸")
        }
        if size.isFixed {
            return size
        }
        if size.isRatio {
            return .fix(size.ratio * relayLength)
        }
        fatalError()
    }
    
    static func caculate(calSize: CalSize, by fixedSize: CalFixedSize) -> CalSize {
        guard !calSize.main.isWrap && !calSize.cross.isWrap else {
            fatalError("不能计算包裹size")
        }
        
        var main = calSize.main
        if main.isRatio {
            main = .fix(main.ratio * fixedSize.main)
        }
        
        var cross = calSize.cross
        if cross.isRatio {
            cross = .fix(cross.ratio * fixedSize.cross)
        }
        return CalSize(main: main, cross: cross, direction: calSize.direction)
    }
    
    static func sizeThatFit(size: CGSize, to measure: Measure) -> CGSize {
        let temp = Measure()
        temp.py_size = size
        let sizeAfterCalulate = measure.caculate(byParent: temp)
        let fixedSize = Caculator.caculate(size: sizeAfterCalulate, by: size)
        return CGSize(width: fixedSize.width.fixedValue, height: fixedSize.height.fixedValue)
    }
    
    static func adapting(size: Size, to measure: Measure, in parent: Measure) {
        let parentCGSize = parent.py_size
        let margin = measure.margin
        
        let wrappedSize = CGSize(width: max(0, parentCGSize.width - margin.left - margin.right),
                                 height: max(0, parentCGSize.height - margin.top - margin.bottom))
        
        // 本身固有尺寸
        if size.isFixed() || size.isRatio() {
            let size = Caculator.caculate(size: size, by: wrappedSize)
            measure.py_size = CGSize(width: size.width.fixedValue, height: size.height.fixedValue)
        } else {
            if !size.width.isWrap {
                let width = Caculator.caculateFix(size.width, by: wrappedSize.width)
                measure.py_size.width = width.fixedValue
            }
            if !size.height.isWrap {
                let height = Caculator.caculateFix(size.height, by: wrappedSize.height)
                measure.py_size.height = height.fixedValue
            }
        }
    }
}
