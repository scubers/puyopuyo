//
//  SizeModifiable.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/8/26.
//

import Foundation

public protocol ValueModifiable {
    func modifyValue() -> SimpleOutput<CGFloat>
}

public struct Simulate {
    var view: UIView

    var transform: (CGRect) -> CGFloat = { _ in 0 }
    var actions = [(CGFloat) -> CGFloat]()

    var selfSimulating = false

    public init(_ view: UIView) {
        self.view = view
    }

    private init() {
        view = UIView()
        selfSimulating = true
    }

    public static var ego: Simulate {
        return Simulate()
    }

    public func add(_ add: CGFloat) -> Simulate {
        var s = self
        s.actions.append { $0 + add }
        return s
    }

    public func multiply(_ multiply: CGFloat) -> Simulate {
        var s = self
        s.actions.append { $0 * multiply }
        return s
    }

    public func simulate(_ view: UIView) -> Simulate {
        var s = self
        s.view = view
        return s
    }

    public func simulateSelf() -> Simulate {
        var s = self
        s.selfSimulating = true
        return s
    }
}

extension Simulate: ValueModifiable {
    public var height: Simulate {
        var s = self
        s.transform = { $0.height }
        return s
    }

    public var width: Simulate {
        var s = self
        s.transform = { $0.width }
        return s
    }

    public var top: Simulate {
        var s = self
        s.transform = { $0.origin.y }
        return s
    }

    public var left: Simulate {
        var s = self
        s.transform = { $0.origin.x }
        return s
    }

    public var bottom: Simulate {
        var s = self
        s.transform = { $0.maxY }
        return s
    }

    public var right: Simulate {
        var s = self
        s.transform = { $0.maxX }
        return s
    }

    public func modifyValue() -> SimpleOutput<CGFloat> {
        let transform = self.transform
        let actions = self.actions
        let kvo = view.py_frameStateByKVO().distinct().map { CGRect(origin: .zero, size: $0.size) }
        let bs = view.py_frameStateByBoundsCenter()
        return SimpleOutput.merge([kvo, bs])
            .map { actions.reduce(transform($0)) { $1($0) } }
            .distinct()
    }
}

extension ValueModifiable {
    public func checkSelfSimulate(_ view: UIView) -> ValueModifiable {
        if let m = self as? Simulate, m.selfSimulating {
            return m.simulate(view)
        }
        return self
    }
}

extension State: ValueModifiable where Value == CGFloat {
    public func modifyValue() -> SimpleOutput<CGFloat> {
        return asOutput().map { $0 }
    }
}
