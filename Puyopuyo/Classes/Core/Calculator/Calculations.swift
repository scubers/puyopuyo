//
//  Caculations.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/26.
//

import Foundation

/**

 *The struct for calculation*

 Size -> CalSize
 CGSize -> CalFixedSize
 CGPoint -> CalCenter
 UIEdgeInset -> CalEdges

 ------------------------
 direction = x
      forward
 start        end
      backward

 ------------------------
 direction = y
        start
 forward     backward
         end
 ------------------------

 */

public struct CalEdges {
    public var start: CGFloat = 0
    public var forward: CGFloat = 0
    public var end: CGFloat = 0
    public var backward: CGFloat = 0

    public init(insets: BorderInsets, direction: Direction, in semanticDirection: SemanticDirection) {
        switch direction {
        case .horizontal:
            forward = insets.top
            backward = insets.bottom
            if insets.isHorzSemantic {
                switch semanticDirection {
                case .leftToRight:
                    start = insets.leading
                    end = insets.trailing
                case .rightToLeft:
                    start = insets.trailing
                    end = insets.leading
                }
            } else {
                start = insets.left ?? 0
                end = insets.right ?? 0
            }

        case .vertical:
            start = insets.top
            end = insets.bottom
            if insets.isHorzSemantic {
                switch semanticDirection {
                case .leftToRight:
                    forward = insets.leading
                    backward = insets.trailing
                case .rightToLeft:
                    forward = insets.trailing
                    backward = insets.leading
                }
            } else {
                forward = insets.left ?? 0
                backward = insets.right ?? 0
            }
        }
    }

    public init(insets: UIEdgeInsets = .zero, direction: Direction) {
        if case .x = direction {
            start = insets.left
            forward = insets.top
            end = insets.right
            backward = insets.bottom
        } else {
            start = insets.top
            forward = insets.left
            end = insets.bottom
            backward = insets.right
        }
    }

    public var mainFixed: CGFloat {
        return start + end
    }

    public var crossFixed: CGFloat {
        return forward + backward
    }
}

public extension UIEdgeInsets {
    func getCalEdges(by direction: Direction) -> CalEdges {
        return CalEdges(insets: self, direction: direction)
    }

    func getHorzTotal() -> CGFloat {
        return left + right
    }

    func getVertTotal() -> CGFloat {
        return top + bottom
    }
}

public struct CalPoint {
    public var direction: Direction
    public var main: CGFloat = 0
    public var cross: CGFloat = 0

    public init(main: CGFloat = 0, cross: CGFloat = 0, direction: Direction) {
        self.main = main
        self.cross = cross
        self.direction = direction
    }

    public init(point: CGPoint, direction: Direction) {
        self.direction = direction
        if direction == .x {
            main = point.x
            cross = point.y
        } else {
            main = point.y
            cross = point.x
        }
    }

    public func getPoint() -> CGPoint {
        if direction == .x {
            return CGPoint(x: main, y: cross)
        }
        return CGPoint(x: cross, y: main)
    }
}

extension CGPoint {
    func getCalCenter(by direction: Direction) -> CalPoint {
        return CalPoint(point: self, direction: direction)
    }
}

public struct CalSize {
    public private(set) var direction: Direction = .x

    public var main: SizeDescription
    public var cross: SizeDescription
    public init(main: SizeDescription, cross: SizeDescription, direction: Direction) {
        self.main = main
        self.cross = cross
        self.direction = direction
    }

    public init(size: Size, direction: Direction) {
        self.direction = direction
        if case .x = direction {
            main = size.width
            cross = size.height
        } else {
            main = size.height
            cross = size.width
        }
    }

    public func getSize() -> Size {
        if case .x = direction {
            return Size(width: main, height: cross)
        } else {
            return Size(width: cross, height: main)
        }
    }
}

public extension Size {
    func getCalSize(by direction: Direction) -> CalSize {
        return CalSize(size: self, direction: direction)
    }
}

public struct CalFixedSize {
    public private(set) var direction: Direction = .x

    public var main: CGFloat
    public var cross: CGFloat
    public init(main: CGFloat, cross: CGFloat, direction: Direction) {
        self.main = main
        self.cross = cross
        self.direction = direction
    }

    public init(cgSize: CGSize, direction: Direction) {
        self.direction = direction
        if case .x = direction {
            main = cgSize.width
            cross = cgSize.height
        } else {
            main = cgSize.height
            cross = cgSize.width
        }
    }

    public func getSize() -> CGSize {
        if case .x = direction {
            return CGSize(width: main, height: cross)
        } else {
            return CGSize(width: cross, height: main)
        }
    }
}

public extension CGSize {
    func getCalFixedSize(by direction: Direction) -> CalFixedSize {
        return CalFixedSize(cgSize: self, direction: direction)
    }
}

extension CGPoint {
    func add(_ point: CGPoint) -> CGPoint {
        CGPoint(x: x + point.x, y: y + point.y)
    }

    static func getOrigin(center: CGPoint, size: CGSize) -> CGPoint {
        CGPoint(x: center.x - size.width / 2, y: center.y - size.height / 2)
    }
}
