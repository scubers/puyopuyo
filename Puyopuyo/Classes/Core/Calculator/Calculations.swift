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
 CGPoint -> CalPoint
 UIEdgeInset -> CalEdges

 ------------------------
 direction = x
         start
 forward       backward
          end

 ------------------------
 direction = y
      forward
 start        end
      backward
 ------------------------

 */

struct CalEdges {
    private(set) var direction: Direction = .x
    var forward: CGFloat = 0
    var start: CGFloat = 0
    var end: CGFloat = 0
    var backward: CGFloat = 0

    init(leading: CGFloat = 0, start: CGFloat = 0, trailing: CGFloat = 0, end: CGFloat = 0, direction: Direction = .x) {
        self.forward = leading
        self.start = start
        self.backward = trailing
        self.end = end
        self.direction = direction
    }

    init(insets: UIEdgeInsets = .zero, direction: Direction) {
        self.direction = direction
        if case .x = direction {
            forward = insets.left
            start = insets.top
            backward = insets.right
            end = insets.bottom
        } else {
            forward = insets.top
            start = insets.left
            backward = insets.bottom
            end = insets.right
        }
    }

    func getInsets() -> UIEdgeInsets {
        var insets = UIEdgeInsets.zero
        if case .x = direction {
            insets.top = start
            insets.left = forward
            insets.bottom = end
            insets.right = backward
        } else {
            insets.top = forward
            insets.left = start
            insets.bottom = backward
            insets.right = end
        }
        return insets
    }

    var mainFixed: CGFloat {
        return forward + backward
    }

    var crossFixed: CGFloat {
        return start + end
    }
}

extension UIEdgeInsets {
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

struct CalPoint {
    var direction: Direction
    var main: CGFloat = 0
    var cross: CGFloat = 0

    init(main: CGFloat = 0, cross: CGFloat = 0, direction: Direction) {
        self.main = main
        self.cross = cross
        self.direction = direction
    }

    init(point: CGPoint, direction: Direction) {
        self.direction = direction
        if direction == .x {
            main = point.x
            cross = point.y
        } else {
            main = point.y
            cross = point.x
        }
    }

    func getPoint() -> CGPoint {
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

struct CalSize {
    private(set) var direction: Direction = .x

    var main: SizeDescription
    var cross: SizeDescription
    init(main: SizeDescription, cross: SizeDescription, direction: Direction) {
        self.main = main
        self.cross = cross
        self.direction = direction
    }

    init(size: Size, direction: Direction) {
        self.direction = direction
        if case .x = direction {
            main = size.width
            cross = size.height
        } else {
            main = size.height
            cross = size.width
        }
    }

    func getSize() -> Size {
        if case .x = direction {
            return Size(width: main, height: cross)
        } else {
            return Size(width: cross, height: main)
        }
    }
}

extension Size {
    func getCalSize(by direction: Direction) -> CalSize {
        return CalSize(size: self, direction: direction)
    }
}

struct CalFixedSize {
    private(set) var direction: Direction = .x

    var main: CGFloat
    var cross: CGFloat
    init(main: CGFloat, cross: CGFloat, direction: Direction) {
        self.main = main
        self.cross = cross
        self.direction = direction
    }

    init(cgSize: CGSize, direction: Direction) {
        self.direction = direction
        if case .x = direction {
            main = cgSize.width
            cross = cgSize.height
        } else {
            main = cgSize.height
            cross = cgSize.width
        }
    }

    func getSize() -> CGSize {
        if case .x = direction {
            return CGSize(width: main, height: cross)
        } else {
            return CGSize(width: cross, height: main)
        }
    }
}

extension CGSize {
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
