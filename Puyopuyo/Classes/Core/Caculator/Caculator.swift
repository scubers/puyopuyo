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
        let width = caculateFix(width: size.width, by: cgSize.width)
        let height = caculateFix(height: size.height, by: cgSize.height)
        return Size(width: width, height: height)
    }
    
    static func caculateFix(height: SizeDescription, by relayHeight: CGFloat) -> SizeDescription {
        guard !height.isWrap else {
            fatalError("不能计算包裹尺寸")
        }
        if height.isFixed {
            return height
        }
        if height.isRatio {
            return .fix(height.ratio * relayHeight)
        }
        fatalError()
    }
    
    static func caculateFix(width: SizeDescription, by relayWidth: CGFloat) -> SizeDescription {
        guard !width.isWrap else {
            fatalError("不能计算包裹尺寸")
        }
        if width.isFixed {
            return width
        }
        if width.isRatio {
            return .fix(width.ratio * relayWidth)
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
}
