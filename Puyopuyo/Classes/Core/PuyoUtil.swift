//
//  PuyoUtil.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import Foundation

class PuyoUtil {
    
    static func point(from offset: CalCenter, fixedSize: CalFixedSize, by direction: Direction, reverse: Bool = false) -> CGPoint {
        
        var finalOffset = offset
//        if reverse {
//            finalOffset = CalCenter(main: offset.main * -1 + fixedSize.main, cross: offset.cross * -1 + fixedSize.cross)
//        }
        
        var point: CGPoint
        if case .y = direction {
            point = CGPoint(x: finalOffset.cross, y: finalOffset.main)
        } else {
            point = CGPoint(x: finalOffset.main, y: fixedSize.cross - finalOffset.cross)
        }
        return point
    }
    
    /*
    static func fixedSize(from cgSize: CGSize?, parentDirection direction: Direction) -> FixedSize {
        let size = cgSize ?? .zero
        if case .x = direction {
            return FixedSize(main: size.width, cross: size.height)
        }
        return FixedSize(main: size.height, cross: size.width)
    }
    
    static func size(from cgSize: CGSize?, parentDirection direction: Direction) -> Size {
        let size = cgSize ?? .zero
        if case .x = direction {
            return Size(main: .fixed(size.width), cross: .fixed(size.height))
        }
        return Size(main: .fixed(size.height), cross: .fixed(size.width))
    }
    
    static func widthSize(from size: Size, parentDirection direction: Direction) -> SizeType {
        if case .x = direction {
            return size.main
        }
        return size.cross
    }
    
    static func heightSize(from size: Size, parentDirection direction: Direction) -> SizeType {
        if case .x = direction {
            return size.cross
        }
        return size.main
    }
    
    static func cgSize(from size: Size, parentDirection direction: Direction) -> CGSize {
        guard case .fixed(let main) = size.main else {
            fatalError()
        }
        guard case .fixed(let cross) = size.cross else {
            fatalError()
        }
        if case .x = direction {
            return CGSize(width: main, height: cross)
        }
        return CGSize(width: cross, height: main)
    }
    
    static func point(from offset: Offset, fixedPosition: FixedSize, by direction: Direction, reverse: Bool = false) -> CGPoint {
        
        var finalOffset = offset
        if reverse {
            finalOffset = Offset(main: offset.main * -1 + fixedPosition.main, cross: offset.cross * -1 + fixedPosition.cross)
        }
        
        var point: CGPoint
        if case .y = direction {
            point = CGPoint(x: finalOffset.cross, y: finalOffset.main)
        } else {
            point = CGPoint(x: finalOffset.main, y: fixedPosition.cross - finalOffset.cross)
        }
        return point
    }
    
    static func fixedPosition(from cgSize: CGSize?, by direction: Direction) -> FixedSize {
        let myCGSize = cgSize ?? .zero
        if case .x = direction {
            return FixedSize(main: myCGSize.width, cross: myCGSize.height)
        }
        return FixedSize(main: myCGSize.height, cross: myCGSize.width)
    }
    
    static func fixedSize(by direction: Direction, cgSize: CGSize? = nil) -> Size {
        let myCGSize = cgSize ?? .zero
        if case .x = direction {
            return Size(main: .fixed(myCGSize.width), cross: .fixed(myCGSize.height))
        }
        return Size(main: .fixed(myCGSize.height), cross: .fixed(myCGSize.width))
    }
    
    static func fixedMainSize(by direction: Direction, cgSize: CGSize? = nil) -> CGFloat {
        if case .fixed(let value) = fixedSize(by: direction, cgSize: cgSize).main {
            return value
        }
        fatalError()
    }
    
    static func fixedCrossSize(by direction: Direction, cgSize: CGSize? = nil) -> CGFloat {
        if case .fixed(let value) = fixedSize(by: direction, cgSize: cgSize).cross {
            return value
        }
        fatalError()
    }
    
    static func cgSize(from: Size, by direction: Direction) -> CGSize {
        guard case .fixed(let main) = from.main else {
            fatalError()
        }
        guard case .fixed(let cross) = from.cross else {
            fatalError()
        }
        if case .x = direction {
            return CGSize(width: main, height: cross)
        }
        return CGSize(width: cross, height: main)
    }
    

    
    static func position(from size: CGSize, direction: Direction) -> FixedSize {
        if case .y = direction {
            return FixedSize(main: size.height, cross: size.width)
        }
        return FixedSize(main: size.width, cross: size.height)
    }
    
    static func cgSize(from position: FixedSize, direction: Direction) -> CGSize {
        if case .y = direction {
            return CGSize(width: position.cross, height: position.main)
        }
        return CGSize(width: position.main, height: position.cross)
    }
    */
}
