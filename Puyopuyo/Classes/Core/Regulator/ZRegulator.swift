//
//  ZLayout.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

public class ZRegulator: Regulator {
    public override func caculate(byParent parent: Measure, remain size: CGSize) -> Size {
        return ZCaculator(self, parent: parent, remain: size).caculate()
    }
}

public protocol Resizable {
    func resizing() -> SimpleOutput<CGRect>
}

extension UIView: Resizable {
    public func resizing() -> SimpleOutput<CGRect> {
        return py_frameStateByKVO()
    }
}

extension Simulate {
    func adapt() -> SimpleOutput<CGFloat> {
        let transform = self.transform
        let actions = self.actions
        return
            SimpleOutput
            .merge([view.py_frameStateByKVO(), view.py_frameStateByBoundsCenter()])
            .distinct()
            .map({ actions.reduce(transform($0)) { $1($0) } })
            .distinct()
    }
}

public class CRegulator: Regulator {
    private var Disposables = [String: Disposable]()

    public override var py_size: CGSize {
        didSet {
            egoChange.input(value: getFrame())
        }
    }

    public override var py_center: CGPoint {
        didSet {
            egoChange.input(value: getFrame())
        }
    }

    private let egoChange = SimpleIO<CGRect>()

    private func getFrame() -> CGRect {
        return CGRect(x: py_center.x - py_size.width / 2, y: py_center.y - py_size.height / 2, width: py_size.width, height: py_size.height)
    }

    private func set(_ Disposable: Disposable?, by key: String) {
        Disposables.removeValue(forKey: key)?.dispose()
        Disposables[key] = Disposable
    }

    public var width: Simulate? {
        didSet {
            let Disposable = width?.adapt().outputing({ [weak self] value in
                self?.py_size.width = value
            })
            set(Disposable, by: "width")
        }
    }

    public var height: Simulate? {
        didSet {
            let Disposable = height?.adapt().outputing({ [weak self] value in
                self?.py_size.height = value
            })
            set(Disposable, by: "height")
        }
    }

//    public var top: Constraint?
//    public var bottom: Constraint?
//    public var left: Constraint?
//    public var right: Constraint?
//    public var centerY: Constraint?
//    public var centerX: Constraint?
}
