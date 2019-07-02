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
        guard !size.width.isWrap && !size.height.isWrap else {
            fatalError("不能计算包裹size")
        }
        var width = size.width
        if width.isRatio {
            width = .fixed(width.ratio * cgSize.width)
        }
        
        var height = size.height
        if height.isRatio {
            height = .fixed(height.ratio * cgSize.height)
        }
        return Size(width: width, height: height)
    }
    
    static func caculate(calSize: CalSize, by fixedSize: CalFixedSize) -> CalSize {
        guard !calSize.main.isWrap && !calSize.cross.isWrap else {
            fatalError("不能计算包裹size")
        }
        
        var main = calSize.main
        if main.isRatio {
            main = .fixed(main.ratio * fixedSize.main)
        }
        
        var cross = calSize.cross
        if cross.isRatio {
            cross = .fixed(cross.ratio * fixedSize.cross)
        }
        return CalSize(main: main, cross: cross, direction: calSize.direction)
    }
}
