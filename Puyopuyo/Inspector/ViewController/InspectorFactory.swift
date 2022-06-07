//
//  InspectorFactory.swift
//  Puyopuyo
//
//  Created by J on 2022/6/8.
//

import Foundation

public enum InspectorFactory {
    public static func createInsepectViewController(_ puzzle: PuzzlePiece? = nil) -> UIViewController {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return PhoneViewController(store: BuilderStore.store(with: puzzle))
        }
        return PadViewController(store: BuilderStore.store(with: puzzle))
    }

    public static func startInsepct(_ puzzle: PuzzlePiece? = nil, from responder: UIResponder?) {
        findTopViewController(for: responder)?.present(createInsepectViewController(puzzle), animated: true)
    }
}

public extension Puyo where T: UIView {
    @discardableResult
    func longPressInspectable() -> Self {
        view.attach { v in
            let id = "abcd"
            v.gestureRecognizers?.filter { $0.styleIdentifier == id }.forEach { v.removeGestureRecognizer($0) }
            let press = UILongPressGestureRecognizer()
            press.py_addAction { g in
                if g.state == .ended {
                    InspectorFactory.startInsepct(g.view, from: g.view)
                }
            }
            press.styleIdentifier = id
            v.addGestureRecognizer(press)
        }
        return self
    }
}
